# Pre-Deployment and Production Release Checklist

This guide explains the checks a team should complete before deploying an application to production. Production is the live environment used by real users, so the goal is to release safely, protect data, and make recovery quick if something goes wrong.

---

## 1. Scope and Approvals

- [ ] **Requirements are complete and approved.**
  - Confirm that the change solves the requested business problem and meets its acceptance criteria.
  - Keep the release small enough to understand. Avoid mixing unrelated changes in one production deployment.

- [ ] **A release owner is identified.**
  - This person coordinates the deployment, makes the go/no-go decision, and communicates progress.

- [ ] **The change is reviewed.**
  - At least one developer should review the code for correctness, security, maintainability, and unintended side effects.
  - Resolve critical and high-severity review findings before production release.

- [ ] **Stakeholders have approved the release.**
  - Depending on the team, this can include the product owner, QA, engineering lead, security team, or change manager.

## 2. Code and Build Quality

- [ ] **The production artifact is built successfully.**
  - An artifact is the exact deployable output: for example, a `.zip` package, Docker image, NuGet package, or Angular build.
  - Deploy the same tested artifact to production. Do not rebuild manually during the release, because that can create a different result.

- [ ] **The correct version is tagged and traceable.**
  - Record the Git commit ID, build number, Docker image tag, or release version.
  - This makes it possible to identify exactly what is running and to return to the previous version.

- [ ] **Dependencies are checked.**
  - Confirm third-party libraries have no known critical vulnerabilities.
  - Verify that package versions are locked or otherwise reproducible.

- [ ] **Code quality checks pass.**
  - Run the repository's formatting, linting, static-analysis, and compilation checks.
  - Treat new compiler warnings seriously, especially nullability, security, and obsolete API warnings.

## 3. Testing

- [ ] **Automated tests pass.**
  - Run unit tests to validate individual classes and methods.
  - Run integration tests to validate databases, queues, external APIs, and other real dependencies.
  - Run API or end-to-end tests for the main user journeys.

- [ ] **Regression testing is complete.**
  - A regression test confirms that existing features still work after the change.
  - Focus on the workflows that depend on the changed component, not only the new feature.

- [ ] **User acceptance testing is signed off when needed.**
  - QA or business users should verify the change in a staging or UAT environment that resembles production.

- [ ] **Performance is acceptable.**
  - For high-traffic or critical changes, run load testing and compare response time, error rate, and resource use with agreed limits.

## 4. Environment and Configuration

- [ ] **Production configuration is verified.**
  - Check service URLs, allowed origins (CORS), feature flags, logging levels, timeout values, email settings, and scheduled-job settings.
  - Confirm production points only to production dependencies. A production application must never accidentally write to a test database.

- [ ] **Secrets are secure.**
  - Store passwords, connection strings, certificates, API keys, and tokens in Azure Key Vault or an equivalent secret store.
  - Do not put secrets in source code, Markdown files, deployment logs, or client-side application settings.

- [ ] **Feature flags are planned.**
  - When possible, release new functionality behind a feature flag.
  - This lets the team disable a risky feature without redeploying the whole application.

- [ ] **Access and networking are validated.**
  - Confirm managed identities, service accounts, RBAC roles, firewall rules, private endpoints, DNS, and certificates work in production.
  - Apply least privilege: each application identity receives only the permissions it needs.

## 5. Database and Data Changes

- [ ] **Database changes are tested against production-like data.**
  - Review schema migrations, stored procedures, indexes, data backfills, and cleanup scripts.
  - Estimate how long the change will take and whether it locks tables or causes downtime.

- [ ] **Changes are backward compatible.**
  - A safe common sequence is: add a new column or field, deploy application code that supports both old and new formats, migrate data, then remove old fields in a later release.
  - This matters during rolling deployments because old and new application versions can run at the same time.

- [ ] **Data backups and recovery are confirmed.**
  - Verify backup retention and point-in-time restore capability before running a destructive or high-risk data change.

- [ ] **A database rollback plan exists.**
  - Application rollback is often easy; data rollback may not be.
  - Document whether rollback uses a down migration, a compensating script, a restore, or a forward fix.

## 6. Infrastructure, Capacity, and Security

- [ ] **Infrastructure is ready for expected traffic.**
  - Check CPU, memory, storage, connection limits, quotas, autoscaling rules, and available capacity.
  - Verify that scale-out rules can handle expected peaks without creating excessive cost.

- [ ] **Health checks are configured.**
  - A liveness check determines whether the application process is running.
  - A readiness check determines whether it can safely receive traffic, including required dependency checks where appropriate.

- [ ] **Security controls are reviewed.**
  - Confirm HTTPS certificates are valid, security headers are appropriate, and sensitive endpoints require authentication and authorization.
  - Check that diagnostics and error responses do not expose secrets or internal implementation details.

## 7. Monitoring and Operational Readiness

- [ ] **Monitoring is available before deployment.**
  - Configure Application Insights or equivalent telemetry for requests, dependencies, exceptions, traces, and availability tests.
  - Ensure dashboards show the key release signals: availability, response time, request volume, error rate, and dependency failures.

- [ ] **Alerts are actionable.**
  - Alerts should notify the right on-call team for sustained failures, high error rates, unhealthy instances, or exhausted capacity.
  - Avoid alerts that are too noisy; alerts should indicate a condition someone can investigate or act on.

- [ ] **Support information is available.**
  - Record known limitations, support contacts, escalation steps, and the locations of logs and dashboards.

## 8. Deployment and Rollback Plan

- [ ] **The deployment plan is documented.**
  - Include release time, release owner, commands or pipeline, deployment order, dependencies, and expected duration.
  - Identify any manual steps and assign an owner for each one.

- [ ] **The release window is suitable.**
  - Avoid known peak periods unless the change is specifically intended to handle that load.
  - Ensure developers, support staff, and required approvers are available during and shortly after the release.

- [ ] **A rollback plan is ready and tested.**
  - Identify the previous stable artifact or image tag and the exact rollback command or pipeline stage.
  - Define rollback triggers, such as a sustained error-rate increase, failing smoke test, or critical business workflow failure.

- [ ] **Communications are prepared.**
  - Notify affected teams before the release and announce the outcome afterward.
  - Include expected impact, maintenance window, rollback status, and support contact where relevant.

## 9. Azure Cosmos DB Checks

Use these checks when the application uses Azure Cosmos DB for NoSQL.

- [ ] **Partition key and access patterns are reviewed.**
  - The partition key should have high cardinality, distribute traffic evenly, and support the most common queries.
  - Avoid low-cardinality partition keys such as `status` or `country`, which can cause hot partitions.

- [ ] **RU capacity is sufficient.**
  - Request Units (RUs) are the throughput cost of Cosmos DB operations.
  - Check current RU use, autoscale or provisioned throughput, and expected release traffic. Validate that the application handles `429 Request Rate Too Large` responses using the SDK retry-after guidance.

- [ ] **Indexes and queries are tested.**
  - Test new queries in a production-like environment and inspect their RU charge and latency.
  - Review indexing-policy changes carefully because they can affect write cost and query performance.

- [ ] **Data safety and regional settings are confirmed.**
  - Confirm backups, retention, multi-region configuration, failover policy, and consistency level match the application's requirements.
  - If the application logs unexpected failures or slow Cosmos DB calls, capture SDK diagnostics to investigate latency and RU usage.

## 10. Release-Day Sequence

1. Confirm approvals, test results, artifact version, and rollback artifact.
2. Verify production configuration, secrets, dashboards, alerts, and on-call availability.
3. Deploy using the approved pipeline and avoid unplanned manual production changes.
4. Run smoke tests immediately after deployment.
5. Watch dashboards and logs closely during the agreed monitoring period.
6. Communicate the release result, including any known issue or rollback decision.

## 11. Post-Deployment Smoke Tests

Smoke tests are short checks that show whether the most important functions work after release.

- [ ] Application health endpoint returns a healthy response.
- [ ] Users can sign in and receive the correct authorization level.
- [ ] A critical API request succeeds and returns expected data.
- [ ] The UI loads and can complete the primary workflow.
- [ ] Background jobs, queues, and scheduled tasks start and process safely.
- [ ] Application logs contain no unexpected error spike.
- [ ] Database writes and reads work as expected without data corruption.
- [ ] Monitoring and alerts receive telemetry from the new version.

## Go / No-Go Decision

Proceed only when all required checklist items are complete, the responsible people approve the release, and the team can roll back quickly. Stop the release when there is an unresolved security issue, failed critical test, unknown database impact, missing monitoring, or no practical rollback path.
