# Sitecore CMS - Interview Guide

## What is Sitecore?

**Sitecore** is a .NET-based Content Management System (CMS) and Digital Experience Platform. It's used for building websites, managing content, and personalizing user experiences.

**Key Features:**
- Content management
- Personalization
- Marketing automation
- Analytics
- Multisite support
- Multilingual support

---

## 1. Core Concepts

### Content Tree Structure

**Definition**: Hierarchical organization of content in Sitecore

**Structure:**
```
/sitecore
  /content
    /Home
      /About
      /Products
        /Product1
        /Product2
      /Contact
  /system
  /templates
  /media library
```

**Key Folders:**
- **/sitecore/content**: Website content
- **/sitecore/templates**: Data templates
- **/sitecore/media library**: Images, documents
- **/sitecore/system**: System items, settings

**Navigation:**
- Content Editor: Visual tree navigation
- Left panel: Content tree
- Right panel: Item details

### Templates and Standard Values

**Templates:**
- Define structure of content items
- Like database schemas
- Define fields (text, rich text, images, etc.)

**Template Hierarchy:**
```
Base Template
  └─ Page Template
      └─ Article Template
      └─ Product Template
```

**Standard Values:**
- Default values for items created from template
- Set on template itself
- Applied when new item is created

**Example:**
- Template: "Article Template"
- Standard Values: 
  - Default layout
  - Default workflow state
  - Default values for fields

**Creating Templates:**
1. Content Editor → Templates
2. Create new template
3. Add sections (groups of fields)
4. Add fields (text, rich text, image, etc.)
5. Set standard values

### Rendering and Layouts

**Layouts:**
- Define page structure (HTML skeleton)
- Contain placeholders
- One layout per page

**Renderings (Components):**
- Reusable components
- Examples: Header, Footer, Navigation, Content Block
- Can be placed in placeholders

**Placeholders:**
- Areas in layout where renderings can be placed
- Defined in layout: `<sc:placeholder key="main" runat="server" />`
- Renderings added via Experience Editor or code

**Rendering Types:**
- **View Renderings**: MVC views (.cshtml)
- **Controller Renderings**: MVC controllers
- **XSLT Renderings**: Legacy XSLT (older versions)
- **Web Controls**: Web Forms (legacy)

**Example Structure:**
```
Layout: MainLayout.cshtml
  └─ Placeholder: header
      └─ Rendering: HeaderComponent
  └─ Placeholder: main
      └─ Rendering: ContentBlock
      └─ Rendering: ImageGallery
  └─ Placeholder: footer
      └─ Rendering: FooterComponent
```

### Placeholders

**Purpose**: Define areas where renderings can be added

**Defining Placeholders:**
```html
<!-- In Layout -->
<sc:placeholder key="main" runat="server" />
<sc:placeholder key="sidebar" runat="server" />
```

**Allowed Placeholders:**
- Restrict which renderings can be added
- Configure in rendering definition
- Prevents incorrect component placement

**Dynamic Placeholders:**
- Multiple instances of same placeholder
- Useful for repeatable sections
- Example: Multiple content blocks on same page

### Publishing Workflow

**Purpose**: Control when content goes live

**Workflow States:**
- **Draft**: Being edited
- **Awaiting Approval**: Submitted for review
- **Approved**: Ready to publish
- **Published**: Live on website

**Publishing Process:**
1. Content author creates/edits item
2. Submits for approval (workflow)
3. Approver reviews
4. Publisher publishes to web database
5. Content appears on website

**Publishing Targets:**
- **Master Database**: Authoring (editing)
- **Web Database**: Live website (published content)
- **Core Database**: System data

**Publishing Modes:**
- **Incremental**: Only changed items
- **Full**: All items
- **Smart**: Only items in workflow final state

---

## 2. Development

### Sitecore API (Item API)

**Getting Items:**
```csharp
// Get item by path
Item item = Sitecore.Context.Database.GetItem("/sitecore/content/Home");

// Get item by ID
Item item = Sitecore.Context.Database.GetItem(new ID("{guid-here}"));

// Get item by GUID string
Item item = Sitecore.Context.Database.GetItem("{guid-here}");
```

**Accessing Fields:**
```csharp
string title = item["Title"];
string body = item.Fields["Body"].Value;

// With null checking
string title = item.Fields["Title"]?.Value ?? string.Empty;
```

**Getting Children:**
```csharp
Item[] children = item.Children.ToArray();
foreach (Item child in item.Children)
{
    // Process child
}
```

**Querying Items:**
```csharp
// Sitecore Query
Item[] items = item.Axes.SelectItems("./descendant-or-self::*[@TemplateID='{template-guid}']");

// Fast Query
string query = "fast:/sitecore/content//*[@@templatename='Article']";
Item[] items = Sitecore.Context.Database.SelectItems(query);
```

### Database API

**Databases:**
- **Master**: Authoring database
- **Web**: Published content (live)
- **Core**: System configuration

**Switching Databases:**
```csharp
Database masterDb = Sitecore.Configuration.Factory.GetDatabase("master");
Database webDb = Sitecore.Configuration.Factory.GetDatabase("web");

Item item = masterDb.GetItem("/sitecore/content/Home");
```

**Context Database:**
```csharp
// Current database (usually web in front-end)
Database db = Sitecore.Context.Database;
```

### Custom Pipelines

**Purpose**: Extend Sitecore functionality

**Common Pipelines:**
- `httpRequestBegin`: Process HTTP requests
- `renderField`: Customize field rendering
- `publish`: Customize publishing
- `saveUI`: Customize item saving

**Creating Pipeline Processor:**
```csharp
public class CustomRequestProcessor
{
    public void Process(Sitecore.Pipelines.HttpRequest.HttpRequestArgs args)
    {
        // Custom logic
        if (args.LocalPath.StartsWith("/api/"))
        {
            // Handle API requests
        }
    }
}
```

**Configuration:**
```xml
<configuration>
  <sitecore>
    <pipelines>
      <httpRequestBegin>
        <processor type="MyNamespace.CustomRequestProcessor, MyAssembly" />
      </httpRequestBegin>
    </pipelines>
  </sitecore>
</configuration>
```

### Custom Processors

**Examples:**
- Custom field types
- Custom workflow actions
- Custom publishing handlers
- Custom media handlers

**Workflow Action:**
```csharp
public class SendEmailAction
{
    public void Process(WorkflowPipelineArgs args)
    {
        Item item = args.DataItem;
        // Send email notification
    }
}
```

### Sitecore MVC

**Controller Rendering:**
```csharp
public class ArticleController : SitecoreController
{
    public ActionResult Article()
    {
        Item item = Sitecore.Context.Item;
        var model = new ArticleViewModel
        {
            Title = item["Title"],
            Body = item["Body"]
        };
        return View(model);
    }
}
```

**View Rendering:**
```csharp
@model MyNamespace.ArticleViewModel
@using Sitecore.Mvc

<div>
    <h1>@Model.Title</h1>
    @Html.Sitecore().Field("Body")
</div>
```

**Getting Context Item:**
```csharp
Item currentItem = Sitecore.Context.Item;
Item homeItem = Sitecore.Context.Site.StartPath;
```

### Helix Architecture (If Applicable)

**Principles:**
- **Foundation**: Reusable low-level components
- **Feature**: Business features (independent)
- **Project**: Site-specific implementations

**Structure:**
```
Solution
  └─ Foundation
      └─ Foundation.Serialization
      └─ Foundation.DependencyInjection
  └─ Feature
      └─ Feature.Articles
      └─ Feature.Navigation
  └─ Project
      └─ Project.Website
```

**Benefits:**
- Modularity
- Reusability
- Testability
- Maintainability

---

## 3. Configuration

### Sitecore Configuration Files

**Location:** `App_Config/` folder

**Key Files:**
- `Sitecore.config`: Main configuration
- `ConnectionStrings.config`: Database connections
- `Sitecore.Analytics.config`: Analytics settings
- `Sitecore.Mvc.config`: MVC configuration

**Patch Files:**
- Customize without modifying core files
- Naming: `*.config` (alphabetically loaded)
- Use `<configuration>` root with patches

**Example Patch:**
```xml
<configuration xmlns:patch="http://www.sitecore.net/xmlconfig/">
  <sitecore>
    <settings>
      <setting name="Custom.Setting" value="CustomValue" patch:source="Custom.config" />
    </settings>
  </sitecore>
</configuration>
```

### Connection Strings

**Location:** `App_Config/ConnectionStrings.config`

**Databases:**
```xml
<add name="core" connectionString="..." />
<add name="master" connectionString="..." />
<add name="web" connectionString="..." />
```

**Common Settings:**
- SQL Server connection
- MongoDB (for xDB/analytics)
- Solr/Elasticsearch (for search)

### Indexing Configuration

**Purpose**: Configure search indexes

**Indexes:**
- `sitecore_master_index`: Master database content
- `sitecore_web_index`: Published content
- Custom indexes for specific content

**Configuration:**
```xml
<configuration>
  <sitecore>
    <contentSearch>
      <indexes>
        <index id="sitecore_web_index" type="...">
          <param desc="name">$(id)</param>
          <param desc="core">$(id)_core</param>
          <!-- Index configuration -->
        </index>
      </indexes>
    </contentSearch>
  </sitecore>
</configuration>
```

**Rebuilding Indexes:**
- Control Panel → Indexing Manager
- Rebuild specific index
- Or via code: `ContentSearchManager.GetIndex("sitecore_web_index").Rebuild()`

### Caching Strategies

**Types of Caches:**
- **HTML Cache**: Rendered output
- **Data Cache**: Item data
- **Item Cache**: Item objects
- **Standard Values Cache**: Template standard values

**Cache Configuration:**
```xml
<sitecore>
  <cacheSizes>
    <sites>
      <site name="website">
        <cacheSize>50MB</cacheSize>
      </site>
    </sites>
  </cacheSizes>
</sitecore>
```

**Cache Clearing:**
- Control Panel → Cache Manager
- Clear specific caches
- Or via code: `Sitecore.Caching.CacheManager.ClearAllCaches()`

**Best Practices:**
- Cache frequently accessed items
- Set appropriate cache sizes
- Clear cache after publishing
- Use cache keys for invalidation

---

## Interview Questions to Prepare

1. **What is Sitecore? What are its main features?**
2. **Explain the content tree structure.**
3. **What is the difference between templates and standard values?**
4. **Explain layouts, renderings, and placeholders.**
5. **How does the publishing workflow work?**
6. **How do you get an item using Sitecore API?**
7. **What is the difference between Master and Web databases?**
8. **What are Sitecore pipelines? Give an example.**
9. **How do you create a custom rendering?**
10. **What is Helix architecture? What are its principles?**

