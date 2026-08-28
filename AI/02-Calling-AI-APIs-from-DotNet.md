## 1. Goal and Overview

This note explains **how to call modern AI APIs (OpenAI, Azure OpenAI, Amazon Bedrock) from .NET Web APIs**, with a focus on:

- **How AI APIs work** (requests, tokens, responses).
- **Concrete .NET examples** using `HttpClient`.
- **Configuration and security** for API keys.
- **Production best practices**, error handling, and performance.
- A **step-by-step POC** you can build quickly.

---

## 2. How AI APIs Work (Request, Tokens, Response)

### 2.1 Mental Model: AI as a Stateless HTTP Service

From a backend perspective, most AI APIs are:

- **HTTP endpoints**: `POST /v1/chat/completions`, `POST /openai/deployments/{deployment}/chat/completions`, etc.
- **Inputs**:
  - Model name / deployment (`gpt-4.1`, `gpt-4o-mini`, `gpt-4o-mini` on Azure, `anthropic.claude-3-haiku` on Bedrock).
  - Text prompts or messages (chat format).
  - Optional parameters: temperature, max tokens, system instructions, tools, etc.
- **Outputs**:
  - Generated text/JSON.
  - Metadata (usage, token counts, finish reason).

You call the API with **JSON over HTTPS**, and the provider returns **JSON with the model’s response**.

### 2.2 Tokens: How Billing and Limits Work

- **Token**: A chunk of text (roughly 3–4 characters of English on average).  
- **Token accounting**:
  - **Input tokens**: Prompt text + context you send.
  - **Output tokens**: Model-generated response.
  - **Total tokens** = input + output → used for **billing** and sometimes **rate limits**.
- **Why tokens matter for backend devs**:
  - Cost control: limit `max_tokens` and prompt length.
  - Latency: larger prompts usually mean slower responses.
  - Limits: provider may cap tokens per request and per minute.

### 2.3 Typical Request/Response Shape (Chat Completions)

High-level request (conceptual):

```json
{
  "model": "gpt-4.1",
  "messages": [
    { "role": "system", "content": "You are a helpful assistant." },
    { "role": "user", "content": "Summarize this log file..." }
  ],
  "max_tokens": 256,
  "temperature": 0.3
}
```

High-level response (conceptual):

```json
{
  "id": "chatcmpl-123",
  "model": "gpt-4.1",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Here's a short summary of your logs..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 120,
    "total_tokens": 270
  }
}
```

---

## 3. .NET Web API Setup (High-Level)

### 3.1 Minimal .NET Web API Skeleton

Create a new Web API project:

```bash
dotnet new webapi -n AiCaller.Api
cd AiCaller.Api
```

Program entry point (for .NET 7+ minimal API style):

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// We'll add HttpClient & configuration for AI providers shortly

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/", () => "AI Caller API is running");

app.Run();
```

We will plug in **endpoints that internally call AI APIs using `HttpClient`**.

---

## 4. HttpClient Basics in .NET (For AI Calls)

### 4.1 Why Use HttpClientFactory

- **Avoid `new HttpClient()` per request** – that causes socket exhaustion.
- Use `.AddHttpClient()` / `IHttpClientFactory`:
  - Centralizes configuration (base address, headers, timeouts).
  - Supports named/typed clients.
  - Better for resilience (Polly, retries, circuit breakers).

Register a named client:

```csharp
builder.Services.AddHttpClient("OpenAI", client =>
{
    client.Timeout = TimeSpan.FromSeconds(30);
});
```

Usage in endpoint:

```csharp
app.MapPost("/ai/simple", async (
    [FromServices] IHttpClientFactory httpClientFactory) =>
{
    var client = httpClientFactory.CreateClient("OpenAI");
    // Use client to call external AI API
});
```

You can create **separate named clients** for OpenAI, Azure OpenAI, and Bedrock.

---

## 5. Configuration & Secure API Keys

### 5.1 Use appsettings + Environment Variables (Override in Prod)

`appsettings.json`:

```json
{
  "AiProviders": {
    "OpenAI": {
      "ApiKey": "",
      "BaseUrl": "https://api.openai.com/v1",
      "DefaultModel": "gpt-4.1-mini"
    },
    "AzureOpenAI": {
      "Endpoint": "",
      "ApiKey": "",
      "DeploymentName": "",
      "ApiVersion": "2024-02-15-preview"
    },
    "Bedrock": {
      "Region": "us-east-1",
      "ModelId": "anthropic.claude-3-haiku-20240307"
    }
  }
}
```

**Never commit real API keys.** Instead:

- Use **environment variables**:
  - `AiProviders__OpenAI__ApiKey`
  - `AiProviders__AzureOpenAI__ApiKey`
  - Or cloud secret managers (Azure Key Vault, AWS Secrets Manager).
- Use **user secrets** in local dev (`dotnet user-secrets`) instead of committing secrets.

### 5.2 Options Pattern

Create configuration classes:

```csharp
public sealed class OpenAIOptions
{
    public const string SectionName = "AiProviders:OpenAI";
    public string ApiKey { get; set; } = string.Empty;
    public string BaseUrl { get; set; } = "https://api.openai.com/v1";
    public string DefaultModel { get; set; } = "gpt-4.1-mini";
}

public sealed class AzureOpenAIOptions
{
    public const string SectionName = "AiProviders:AzureOpenAI";
    public string Endpoint { get; set; } = string.Empty;
    public string ApiKey { get; set; } = string.Empty;
    public string DeploymentName { get; set; } = string.Empty;
    public string ApiVersion { get; set; } = "2024-02-15-preview";
}
```

Register them:

```csharp
builder.Services.Configure<OpenAIOptions>(
    builder.Configuration.GetSection(OpenAIOptions.SectionName));
builder.Services.Configure<AzureOpenAIOptions>(
    builder.Configuration.GetSection(AzureOpenAIOptions.SectionName));
```

In production:

- Store API keys in **Key Vault/Secrets Manager**.
- Inject them into environment variables or configuration providers.
- Restrict access via **managed identities** / IAM, not shared credentials.

---

## 6. Calling OpenAI from .NET (Using HttpClient)

### 6.1 Request/Response DTOs (Simplified)

Create minimal DTOs for chat completions:

```csharp
public sealed record ChatMessage(string Role, string Content);

public sealed record ChatCompletionRequest(
    string Model,
    IReadOnlyList<ChatMessage> Messages,
    int MaxTokens = 256,
    double Temperature = 0.3);

public sealed record ChatChoice(int Index, ChatMessage Message, string FinishReason);

public sealed record Usage(int PromptTokens, int CompletionTokens, int TotalTokens);

public sealed record ChatCompletionResponse(
    string Id,
    string Model,
    IReadOnlyList<ChatChoice> Choices,
    Usage Usage);
```

### 6.2 Configure HttpClient for OpenAI

```csharp
builder.Services.AddHttpClient("OpenAI", (sp, client) =>
{
    var options = sp.GetRequiredService<IOptions<OpenAIOptions>>().Value;
    client.BaseAddress = new Uri(options.BaseUrl);
    client.DefaultRequestHeaders.Authorization =
        new AuthenticationHeaderValue("Bearer", options.ApiKey);
    client.DefaultRequestHeaders.Add("User-Agent", "AiCaller.Api/1.0");
    client.Timeout = TimeSpan.FromSeconds(30);
});
```

Required `using` directives:

```csharp
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;
```

### 6.3 Minimal Endpoint Using OpenAI Chat Completions

```csharp
app.MapPost("/openai/chat", async (
    [FromBody] string userPrompt,
    IHttpClientFactory httpClientFactory,
    IOptions<OpenAIOptions> options) =>
{
    var client = httpClientFactory.CreateClient("OpenAI");

    var request = new ChatCompletionRequest(
        Model: options.Value.DefaultModel,
        Messages: new[]
        {
            new ChatMessage("system", "You are a helpful assistant for backend developers."),
            new ChatMessage("user", userPrompt)
        });

    var json = JsonSerializer.Serialize(request);
    using var content = new StringContent(json, Encoding.UTF8, "application/json");

    using var response = await client.PostAsync("/chat/completions", content);

    if (!response.IsSuccessStatusCode)
    {
        var errorBody = await response.Content.ReadAsStringAsync();
        return Results.Problem(
            title: "OpenAI call failed",
            detail: errorBody,
            statusCode: (int)response.StatusCode);
    }

    var responseStream = await response.Content.ReadAsStreamAsync();
    var completion = await JsonSerializer.DeserializeAsync<ChatCompletionResponse>(
        responseStream,
        new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

    var answer = completion?.Choices.FirstOrDefault()?.Message.Content
                 ?? "No response from model.";

    return Results.Ok(new
    {
        answer,
        usage = completion?.Usage
    });
});
```

This endpoint:

- Accepts a plain `string` prompt.
- Calls OpenAI’s `/chat/completions`.
- Handles non-success status codes.
- Returns the assistant’s message + usage.

---

## 7. Calling Azure OpenAI from .NET (Using HttpClient)

### 7.1 Azure OpenAI Endpoint Shape

Azure OpenAI uses **Azure-style endpoints**:

- Base URL: `https://{resource-name}.openai.azure.com`
- Endpoint: `/openai/deployments/{deployment-name}/chat/completions?api-version={version}`
- Auth: `api-key` header.

### 7.2 Configure HttpClient for Azure OpenAI

```csharp
builder.Services.AddHttpClient("AzureOpenAI", (sp, client) =>
{
    var options = sp.GetRequiredService<IOptions<AzureOpenAIOptions>>().Value;
    client.BaseAddress = new Uri(options.Endpoint);
    client.DefaultRequestHeaders.Add("api-key", options.ApiKey);
    client.DefaultRequestHeaders.Add("User-Agent", "AiCaller.Api/1.0");
    client.Timeout = TimeSpan.FromSeconds(30);
});
```

### 7.3 Endpoint to Call Azure OpenAI

```csharp
app.MapPost("/azure-openai/chat", async (
    [FromBody] string userPrompt,
    IHttpClientFactory httpClientFactory,
    IOptions<AzureOpenAIOptions> options) =>
{
    var client = httpClientFactory.CreateClient("AzureOpenAI");

    var request = new
    {
        messages = new[]
        {
            new { role = "system", content = "You are a helpful assistant for .NET backend developers." },
            new { role = "user", content = userPrompt }
        },
        max_tokens = 256,
        temperature = 0.3
    };

    var json = JsonSerializer.Serialize(request);
    using var content = new StringContent(json, Encoding.UTF8, "application/json");

    var path = $"/openai/deployments/{options.Value.DeploymentName}/chat/completions" +
               $"?api-version={options.Value.ApiVersion}";

    using var response = await client.PostAsync(path, content);

    if (!response.IsSuccessStatusCode)
    {
        var errorBody = await response.Content.ReadAsStringAsync();
        return Results.Problem(
            title: "Azure OpenAI call failed",
            detail: errorBody,
            statusCode: (int)response.StatusCode);
    }

    var body = await response.Content.ReadAsStringAsync();
    return Results.Content(body, "application/json");
});
```

This example:

- Uses anonymous types for request.
- Forwards the raw JSON response (you can create typed DTOs similarly to the OpenAI example).

---

## 8. Calling Amazon Bedrock from .NET (High-Level)

### 8.1 Key Concepts

- Bedrock is **AWS’s managed service** for multiple foundation models (Anthropic Claude, etc.).
- Access patterns:
  - **AWS SDK for .NET** (recommended).
  - Direct HTTPS calls (requires AWS v4 signing – more complex).
- You must configure:
  - AWS region (e.g. `us-east-1`).
  - IAM credentials/roles with Bedrock access.

### 8.2 Using AWS SDK for .NET (Bedrock Runtime)

Add the package:

```bash
dotnet add package AWSSDK.BedrockRuntime
```

Configure AWS client:

```csharp
using Amazon;
using Amazon.BedrockRuntime;

builder.Services.AddSingleton<IAmazonBedrockRuntime>(_ =>
    new AmazonBedrockRuntimeClient(RegionEndpoint.USEast1));
```

Example endpoint (Anthropic Claude-style messages, simplified):

```csharp
using Amazon.BedrockRuntime.Model;

app.MapPost("/bedrock/chat", async (
    [FromBody] string userPrompt,
    IAmazonBedrockRuntime bedrockClient,
    IOptions<BedrockOptions> options) =>
{
    var requestBody = /* build JSON per the model's schema */;

    var request = new InvokeModelRequest
    {
        ModelId = options.Value.ModelId,
        ContentType = "application/json",
        Accept = "application/json",
        Body = new MemoryStream(Encoding.UTF8.GetBytes(requestBody))
    };

    var response = await bedrockClient.InvokeModelAsync(request);

    using var reader = new StreamReader(response.Body);
    var body = await reader.ReadToEndAsync();

    return Results.Content(body, "application/json");
});
```

Details of the JSON payload depend on the specific Bedrock model (Anthropic, etc.).  
In production, keep the **model-specific JSON builder** in a separate service/class and unit test it.

---

## 9. Production Best Practices

### 9.1 Reliability & Error Handling

- **Timeouts**:
  - Set reasonable `HttpClient.Timeout` (e.g. 15–30 seconds).
  - Set **shorter timeouts** on upstream calls than your API’s own timeout budget.
- **Retries**:
  - Retry on **transient errors** (5xx, 429) with exponential backoff.
  - Use Polly policies with `AddHttpClient().AddPolicyHandler(...)`.
- **Circuit breakers**:
  - Prevent hammering the AI provider if it’s down.
- **Graceful degradation**:
  - Fallback answers: “The AI is currently unavailable, please try again later.”
  - Cached or rule-based responses for critical flows.

### 9.2 Observability & Logging

- Log:
  - Request correlation IDs.
  - Latency per AI call.
  - Status codes and error details (sanitized).
  - **Prompt templates and truncated responses** (for debugging) – avoid logging sensitive raw data.
- Metrics:
  - Requests per second.
  - Error rate per provider/model.
  - Token usage and cost per tenant/feature.

### 9.3 Security & Compliance

- **PII & sensitive data**:
  - Mask or anonymize before sending to external APIs when possible.
  - Use provider features for **data privacy** (no training on your data) when required.
- **Secrets**:
  - Use secret managers, not plain text configs.
  - Rotate keys regularly; monitor for leaked credentials.
- **Access control**:
  - Enforce per-tenant quotas and authorization before hitting AI providers.

---

## 10. Error Handling Strategies (Detailed)

### 10.1 Distinguish between Categories

- **Client-side validation errors**:
  - Missing/invalid user input → return `400 Bad Request`.
- **Upstream AI errors**:
  - Provider returns `4xx` or `5xx` → translate into appropriate `502/503` for your clients.
- **Timeouts & cancellations**:
  - Use `CancellationToken` from ASP.NET, propagate to `HttpClient`.
- **Deserialization problems**:
  - Wrap `JsonSerializer` calls in try/catch, log the response body for diagnostics (truncate if large).

### 10.2 Example Error-Handling Wrapper

Create a small helper:

```csharp
public static class HttpResponseExtensions
{
    public static async Task<IResult> ToResultOrProblemAsync(this HttpResponseMessage response, string providerName)
    {
        if (response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync();
            return Results.Content(body, "application/json");
        }

        var errorBody = await response.Content.ReadAsStringAsync();
        // Log errorBody with providerName and status code (not shown here)

        var status = (int)response.StatusCode;

        if (status >= 500)
        {
            return Results.Problem(
                title: $"{providerName} upstream error",
                detail: "The upstream AI provider is currently unavailable. Please try again later.",
                statusCode: StatusCodes.Status503ServiceUnavailable);
        }

        return Results.Problem(
            title: $"{providerName} call failed",
            detail: errorBody,
            statusCode: StatusCodes.Status502BadGateway);
    }
}
```

Then use it in endpoints:

```csharp
var result = await response.ToResultOrProblemAsync("OpenAI");
return result;
```

---

## 11. Performance Considerations

### 11.1 Latency

- AI calls are often **100ms–several seconds**.
- Strategies:
  - **Parallelize** independent AI calls with `Task.WhenAll`.
  - Use **streaming APIs** for chat (send tokens as they arrive to client).
  - Cache results for deterministic prompts (e.g. same document + question).

### 11.2 Cost & Token Optimization

- Limit:
  - `max_tokens` for outputs.
  - Length of context you send (truncate history, use summaries).
- Use **cheaper models** (`gpt-4.1-mini`, Claude Haiku) when high throughput is needed and quality trade-off is acceptable.
- Introduce:
  - **Per-tenant quotas**.
  - Feature flags (enable AI only for certain SKUs).

### 11.3 Resilient Architecture

- Don’t call AI directly from **latency-sensitive hot paths** (e.g. synchronous checkout) if possible.
- Consider:
  - Async patterns (queues) for heavy inference work.
  - Dedicated **AI gateway/microservice** to centralize logic and observability.

---

## 12. Step-by-Step POC Instructions

### 12.1 Prerequisites

- .NET 8 SDK (or 7).
- An **OpenAI** or **Azure OpenAI** key.
- (Optional) AWS account with Bedrock access.

### 12.2 Create Project

```bash
dotnet new webapi -n AiCaller.Api
cd AiCaller.Api
dotnet add package Microsoft.Extensions.Http
dotnet add package Microsoft.Extensions.Options.ConfigurationExtensions
```

If using Bedrock:

```bash
dotnet add package AWSSDK.BedrockRuntime
```

### 12.3 Configure appsettings

Edit `appsettings.Development.json`:

```json
{
  "AiProviders": {
    "OpenAI": {
      "ApiKey": "",
      "BaseUrl": "https://api.openai.com/v1",
      "DefaultModel": "gpt-4.1-mini"
    },
    "AzureOpenAI": {
      "Endpoint": "https://<your-resource-name>.openai.azure.com",
      "ApiKey": "",
      "DeploymentName": "<your-deployment-name>",
      "ApiVersion": "2024-02-15-preview"
    }
  }
}
```

Set keys via user secrets or environment variables (recommended).

### 12.4 Implement OpenAI Endpoint

- Add:
  - `OpenAIOptions` class.
  - DTOs (`ChatMessage`, `ChatCompletionRequest`, etc.).
  - `AddHttpClient("OpenAI", ...)` registration.
  - `/openai/chat` endpoint as shown earlier.

### 12.5 Run and Test

```bash
dotnet run
```

- Open Swagger UI at `https://localhost:{port}/swagger`.
- Call `POST /openai/chat` with a simple string, e.g. `"Explain dependency injection in .NET for 2 sentences."`.
- Verify:
  - You get a response from the model.
  - Usage info (tokens) is returned.

### 12.6 Add Azure OpenAI (Optional)

- Add `AzureOpenAIOptions` class and config.
- Register `AddHttpClient("AzureOpenAI", ...)`.
- Implement `/azure-openai/chat` endpoint.
- Test with your Azure deployment.

### 12.7 Next Steps / Hardening

- Add:
  - Proper **logging and correlation IDs**.
  - **Retry + timeout policies** via Polly.
  - **Authentication/authorization** on your own API.
- Start extracting AI-calling logic into a dedicated **service class** (`IAiClient`) to support swapping providers.

---

## 13. Summary (Backend-Focused)

- **AI APIs are just HTTP services** with JSON requests/responses and token-based billing; treat them like any other external dependency.
- In .NET, use **`HttpClientFactory` + options + environment variables/secret stores** to call OpenAI, Azure OpenAI, and Bedrock safely.
- For production, focus on **timeouts, retries, circuit breakers, observability, and cost control** around AI calls.
- Start with a small POC endpoint, then gradually evolve toward a **dedicated AI gateway/service** with multi-provider support and strong governance.


