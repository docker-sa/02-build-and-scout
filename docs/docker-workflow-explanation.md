# GitHub Action & Developer Workflow Explanation

## GitHub Actions Workflow

The GitHub Actions workflow in your project (`docker-build.yml`) automates Docker image building, vulnerability scanning, and publishing. It's triggered by two events:

1. **Push events with tags** - When you push a tag to the repository
2. **Pull requests** to the main branch - When PRs are opened or updated

### Key Steps in the Workflow

1. **Setup Environment**
   - Checks out code
   - Sets up QEMU for multi-architecture builds (amd64 and arm64)
   - Configures Docker Buildx for advanced build capabilities
   - Authenticates with Docker Hub

2. **Build and Push Image** (for tags/releases)
   - Builds multi-platform Docker image (amd64 and arm64)
   - Pushes to Docker Hub with the tag name
   - Generates SBOM (Software Bill of Materials) and provenance

3. **Build Image for PRs** (without pushing)
   - Builds multi-platform image but doesn't push to registry
   - Creates a single-platform (amd64) image for scanning

4. **Security Scanning with Docker Scout**
   - For PRs:
     - Quick vulnerability scan
     - Detailed CVE analysis (critical and high severity)
     - Adds scan results as PR comments
   - For tags:
     - Quick vulnerability scan
     - Comprehensive CVE analysis
     - Generates SARIF security report

5. **Report Handling**
   - Uploads SARIF report to GitHub Security tab
   - Updates Docker Hub repository description

### Conditional Execution

The workflow uses conditions to determine which steps run:
- `if: github.event_name == 'push'` for tag-related steps
- `if: github.event_name == 'pull_request'` for PR-related steps

## Developer Workflow

Based on your project files, the developer workflow appears to be:

1. **Development Phase**
   - Develop code on feature branches
   - Make changes to the application (Go application in this case)

2. **Pull Request Phase**
   - Create a PR to merge changes to main
   - GitHub Actions builds the image without pushing
   - Docker Scout scans for vulnerabilities
   - PR receives automated comments with scan results
   - Review and address any security issues

3. **Release Phase**
   - After PR is merged, create a release tag using `create-release-tag.sh`
   - The script sets the version in `release.env`, commits, and pushes the tag
   - GitHub Actions builds and pushes the image to Docker Hub
   - Docker Scout performs comprehensive scanning
   - SARIF report is uploaded to GitHub Security

4. **Maintenance**
   - If needed, remove a tag using `remove-release-tag.sh`

## Workflow Diagrams

### 1. Overall Workflow Trigger Flow

```mermaid
flowchart TD
    subgraph "GitHub Repository"
        A[Repository] --> B[Push Tag]
        A --> C[Create/Update PR]
    end
    
    subgraph "GitHub Actions Workflow"
        D[Build and Push Docker Image]
        E[Run Docker Scout Scanning]
        F[Create Security Reports]
        G[Update Docker Hub Description]
    end
    
    B -->|Triggers| D
    C -->|Triggers| D
    D --> E
    E --> F
    D --> G
    
    style D fill:#c9e6ff,stroke:#0066cc
    style E fill:#ffdddd,stroke:#cc0000
    style F fill:#ffffdd,stroke:#cccc00
    style G fill:#ddffdd,stroke:#00cc00
```

### 2. Docker Build Process by Event Type

```mermaid
stateDiagram-v2
    [*] --> EventCheck
    
    EventCheck --> PushEvent: github.event_name == 'push'
    EventCheck --> PREvent: github.event_name == 'pull_request'
    
    state PushEvent {
        PushStart --> PushBuild: Build with provenance & SBOM
        PushBuild --> PushScan: Push to Docker Hub
        PushScan --> PushReport: Generate & Upload SARIF
    }
    
    state PREvent {
        PRStart --> PRBuild: Build multi-arch (not loaded)
        PRBuild --> PRBuildScan: Build single-arch for scanning
        PRBuildScan --> PRScan: Don't push to Docker Hub
        PRScan --> PRCompare: Compare with prod
        PRCompare --> PRReport: Comment on PR
    }
```

### 3. Developer Release Workflow

```mermaid
flowchart TD
    A[Feature Development] -->|Code complete| B[Create Pull Request]
    B -->|Automated scanning| C[Review Security Results]
    C -->|Address issues| B
    C -->|Approve| D[Merge to Main]
    D -->|Update release.env| E[Run create-release-tag.sh]
    E -->|Git tag pushed| F[GitHub Actions Triggered]
    F -->|Build & Push| G[Multi-arch Docker Image]
    F -->|Scan| H[Security Reports]
    G --> I[Docker Hub Repository]
    H --> J[GitHub Security Tab]
    
    style A fill:#f9f9f9,stroke:#666666
    style B fill:#c9e6ff,stroke:#0066cc
    style C fill:#ffdddd,stroke:#cc0000
    style D fill:#ddffdd,stroke:#00cc00
    style E fill:#f9f9f9,stroke:#666666
    style F fill:#c9e6ff,stroke:#0066cc
    style G fill:#ddffdd,stroke:#00cc00
    style H fill:#ffffdd,stroke:#cccc00
```

### 4. Docker Scout Security Scanning Flow

```mermaid
graph TD
    A[Docker Image] --> B{Event Type?}
    
    B -->|Push| C[Quickview Scan]
    B -->|PR| D[Quickview Scan]
    
    C --> E[Full CVE Analysis]
    D --> F[Critical/High CVE Analysis]
    D --> G[Compare with prod]
    
    E --> H[Generate SARIF]
    F --> I[Generate SARIF]
    
    H --> J[Upload to GitHub Security]
    I --> K[Comment on PR]
    
    style A fill:#c9e6ff,stroke:#0066cc
    style C fill:#ffdddd,stroke:#cc0000
    style D fill:#ffdddd,stroke:#cc0000
    style E fill:#ffdddd,stroke:#cc0000
    style F fill:#ffdddd,stroke:#cc0000
    style G fill:#ffdddd,stroke:#cc0000
    style H fill:#ffffdd,stroke:#cccc00
    style I fill:#ffffdd,stroke:#cccc00
```

## Key Highlights

1. **Automated Security Integration**
   - Docker Scout is integrated at multiple points in the workflow
   - Security scanning happens automatically for both PRs and releases
   - Results are integrated into the PR review process

2. **Multi-Platform Support**
   - The workflow builds for both amd64 and arm64 architectures
   - Special handling for PR scanning (single-arch image for scanning)

3. **Different Handling for PRs vs Releases**
   - PRs: Build but don't push; focus on security scanning
   - Releases: Build, scan, and push with full metadata (SBOM and provenance)

4. **Developer-Friendly Tools**
   - Helper scripts (`create-release-tag.sh`, `remove-release-tag.sh`)
   - Automatic PR comments with security insights
   - Documentation in README and docs directory

This CI/CD setup provides a robust workflow for Docker image building, security scanning, and publishing that balances development speed with security best practices.