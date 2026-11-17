# ADR-0002: Deploy the tested Flutter Web artifact with GitHub Actions

## Status

Accepted for the explicitly authorized GitHub Pages publication.

## Context

The repository is public and the user requested a live Flutter lab, a README demo link and verification. A project Pages site serves at `/ml-engine/`; a root-relative build would fail to locate its entry point or rendering resources. Deployment must not bypass the existing checks or publish a Dart package.

## Decision

Extend Verify with a deployment job that depends on the successful verification/build job. Build once using `/ml-engine/` as base href, bundled rendering resources and content-hashed Web entrypoints/assets. Upload that exact build with upload-pages-artifact and deploy it with deploy-pages. Only main pushes/manual runs upload or deploy; pull requests and tags retain verification without Pages write permissions.

Use the github-pages environment and serialize deployments. Grant contents:read by default, and pages:write/id-token:write only to deployment. Keep generated output out of the source tree. Enable workflow-based Pages hosting through the repository API. Retain `publish_to: none` in both manifests.

## Consequences

Positive: the demo corresponds to a tested revision, no separate build branch can drift, rendering resources resolve under the repository path, and failed checks prevent publication. Content hashing reduces stale application bundles after updates. Hosting is static and requires no service account or added deployment secret.

Costs: publishing waits for the full test/build pipeline. GitHub Pages still controls HTML caching and propagation; verify the served commit's assets and reload behavior after deployment. Offline installation is not promised. Domain/root-path changes require a new base href.

## Alternatives considered

Committing build output into a gh-pages branch introduces a second source of deployment state. A separate workflow that independently rebuilds without depending on Verify could publish an untested commit. A paid host/backend is unnecessary for this client-only lab and was not requested.

## References

[Custom Pages workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages), [Flutter Web release build](https://docs.flutter.dev/deployment/web).
