# Docker Build and Scout Security Workflow

This GitHub Actions workflow automates Docker image building and security scanning using Docker Scout. It triggers on two events:
- Push events with tags
- Pull requests to the main branch

## Required Permissions

```yaml
security-events: write  # For SARIF uploads
actions: read          # For Action status
pull-requests: write   # For PR comments
```

## Workflow Stages

### 1. Setup
- Checks out code using `actions/checkout@v4`
- Configures Docker Buildx
- Authenticates with Docker Hub using provided credentials

### 2. Docker Image Build

#### For Tags (Push Events)
- Builds and pushes image to Docker Hub
- Tags: `philippecharriere494/02-hello-scout-demo:{tag}`
- Generates SBOM and provenance
- Repository push enabled

#### For Pull Requests
- Builds image locally
- Tags: `philippecharriere494/02-hello-scout-demo:pr-{PR_number}`
- No SBOM or provenance
- No repository push

### 3. Security Scanning

#### Pull Request Scans
1. **Quick Analysis**
   - Runs `scout quickview` on PR image
   
2. **Production Comparison**
   - Compares PR image with production
   - Focuses on critical and high severity issues
   - Fails workflow if issues found

3. **CVE Analysis**
   - Scans for critical and high severity CVEs
   - Generates SARIF report
   - Posts findings as PR comment
   - Fails workflow if CVEs found

#### Tag Push Scans
1. **Quick Analysis**
   - Runs `scout quickview` on tagged image

2. **CVE Analysis**
   - Scans for all severity CVEs
   - Generates SARIF report
   - Uploads report to GitHub Security

## Important Notes

1. The workflow uses different build configurations for PRs vs tags:
   - PRs: Local build only, no push
   - Tags: Full build with push to registry

2. Security gates are stricter for PRs:
   - Only critical and high severity issues block PRs
   - All severities are recorded for tagged releases

3. Automated PR feedback includes:
   - Security scan results as comments
   - Comparison with production environment
   - Detailed CVE findings