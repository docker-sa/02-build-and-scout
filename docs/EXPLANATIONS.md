# Detailed GitHub Actions Workflow Steps

## 1. Checkout Code
```yaml
- name: 🐙 Checkout code
  uses: actions/checkout@v4
```
Clones the repository into the GitHub Actions runner. Version 4 of the action includes improved performance and security features.

## 2. Setup Docker Buildx
```yaml
- name: Setup Docker buildx
  uses: docker/setup-buildx-action@v3
```
Configures Docker Buildx, which provides:
- Multi-platform image building
- Build caching
- Concurrent building capabilities
- Enhanced build features compared to classic docker build

## 3. Docker Hub Authentication
```yaml
- name: 🐳 Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```
Authenticates with Docker Hub using:
- Stored GitHub repository secrets for credentials
- Secure token handling through GitHub's secrets management
- Required for pushing images to Docker Hub

## 4. Docker Image Build (Push Event)
```yaml
- name: 📦 Build and push Docker image on push
  if: github.event_name == 'push'
  uses: docker/build-push-action@v6
  with:
    context: .
    file: ./Dockerfile
    load: false
    push: true
    tags: philippecharriere494/02-hello-scout-demo:${{ github.ref_name }}
    sbom: true
    provenance: true
```
Triggered on tag push:
- Builds from repository root context
- Uses specified Dockerfile
- Pushes to Docker Hub
- Tags with git tag name
- Generates Software Bill of Materials (SBOM)
- Creates provenance attestation for supply chain security

## 5. Docker Image Build (PR Event)
```yaml
- name: 🎁 Build and push Docker image on PR
  if: github.event_name == 'pull_request'
  uses: docker/build-push-action@v6
  with:
    context: .
    file: ./Dockerfile
    load: true
    push: false
    tags: philippecharriere494/02-hello-scout-demo:pr-${{ github.event.number }}
    sbom: false
    provenance: false
```
Triggered on pull requests:
- Builds image locally only
- No push to registry
- Tags with PR number
- Skips SBOM and provenance for faster PR checks

## 6. Quick Security Scan (PR)
```yaml
- name: 🔍🤔 Run Scout scan on PR
  if: github.event_name == 'pull_request'
  uses: docker/scout-action@v1
  with:
    command: quickview
    image: philippecharriere494/02-hello-scout-demo:pr-${{ github.event.number }}
```
Performs rapid security assessment:
- Basic vulnerability check
- Configuration review
- Quick insights into security posture

## 7. Production Comparison
```yaml
- name: 👀🤔 Compare to deployed image
  id: docker-scout-compare
  if: ${{ github.event_name == 'pull_request_target' }}
  uses: docker/scout-action@main
  with:
    command: compare
    image: philippecharriere494/02-hello-scout-demo:pr-${{ github.event.number }}
    only-severities: critical,high
    to-env: prod
    exit-code: true       
    summary: true
```
Compares PR image with production:
- Focuses on critical and high severity issues
- Checks against production environment
- Fails workflow if serious issues found
- Generates comparison summary

## 8. CVE Analysis (PR)
```yaml
- name: 🚨 Analyze PR for CVEs
  if: github.event_name == 'pull_request'
  uses: docker/scout-action@v1
  with:
    command: cves
    image: philippecharriere494/02-hello-scout-demo:pr-${{ github.event.number }}
    only-severities: critical,high
    exit-code: true
    sarif-file: sarif.output.json
```
Detailed vulnerability scan:
- Checks for known CVEs
- Focuses on critical and high severity
- Generates SARIF format report
- Fails if serious vulnerabilities found

## 9. PR Comment Generation
```yaml
- name: 💬 Comment PR with Scout results
  if: github.event_name == 'pull_request'
  uses: docker/scout-action@v1
  with:
    command: cves
    image: philippecharriere494/02-hello-scout-demo:pr-${{ github.event.number }}
    only-severities: critical,high
    summary: true
    write-comment: true
```
Automated PR feedback:
- Posts scan results as PR comment
- Includes high-severity findings
- Provides actionable security feedback

## 10. Tag Security Scan
```yaml
- name: 🔍 Run Scout scan on tag
  if: github.event_name == 'push'
  uses: docker/scout-action@v1
  with:
    command: quickview
    image: philippecharriere494/02-hello-scout-demo:${{ github.ref_name }}
```
Scans tagged releases:
- Quick security assessment
- Overview of security posture
- Applied to release candidates

## 11. Release CVE Analysis
```yaml
- name: 🐞 Analyze for critical and high CVEs
  id: docker-scout-cves
  if: github.event_name == 'push'
  uses: docker/scout-action@v1
  with:
    command: cves
    image: philippecharriere494/02-hello-scout-demo:${{ github.ref_name }}
    sarif-file: sarif.output.json
    summary: true
```
Comprehensive release scanning:
- Full CVE analysis
- SARIF report generation
- Summary of findings
- Applied to tagged releases

## 12. Security Report Upload
```yaml
- name: 📝 Upload Scout Report
  id: upload-sarif
  if: github.event_name == 'push'
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: sarif.output.json
```
Final security documentation:
- Uploads SARIF report to GitHub
- Integrates with Security tab
- Provides permanent security record
- Enables security tracking over time