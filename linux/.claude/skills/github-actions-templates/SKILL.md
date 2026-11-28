---
name: github-actions-templates
description: "GitHub Actions workflow templates: test matrix, Docker build/push to GHCR, Kubernetes deploy via OIDC, reusable workflows, security scans, SHA-pinned actions, least-privilege permissions. Use when writing or editing .github/workflows/*.yml."
metadata:
  source:
    repo: "github.com/wshobson/agents"
    path: "plugins/cicd-automation/skills/github-actions-templates"
    commit: "c96b5f6552dba32e4492307493ee613581430715"
    license: "MIT"
    checked: "2026-11-27"
---

# GitHub Actions Templates

Production-ready GitHub Actions workflow patterns for testing, building, and deploying applications.

## Purpose

Create efficient, secure GitHub Actions workflows for continuous integration and deployment across various tech stacks.

## When to Use

- Automate testing and deployment
- Build Docker images and push to registries
- Deploy to Kubernetes clusters
- Run security scans
- Implement matrix builds for multiple environments

## Common Workflow Patterns

### Pattern 1: Test Workflow

```yaml
name: Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

permissions:
  contents: read # read-only token by default; widen per job only when needed

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [20.x, 22.x]

    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1

      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/lcov.info
```

### Pattern 2: Build and Push Docker Image

```yaml
name: Build and Push

on:
  push:
    branches: [main]
    tags: ["v*"]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Pattern 3: Deploy to Kubernetes

```yaml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

permissions:
  contents: read
  id-token: write # OIDC: short-lived cloud login, no stored keys

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production # waits for the required reviewers set in repo settings

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-deploy
          aws-region: us-west-2

      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig --name production-cluster --region us-west-2

      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f k8s/
          kubectl rollout status deployment/my-app -n production
          kubectl get services -n production
```

### Pattern 4: Matrix Build

```yaml
name: Matrix Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python-version: ["3.11", "3.12", "3.13"]

    steps:
      - uses: actions/checkout@v4

      - name: Set up uv
        uses: astral-sh/setup-uv@v7
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install dependencies
        run: uv sync --locked

      - name: Run tests
        run: uv run pytest
```

### Pattern 5: Java / Maven

```yaml
name: Maven

on: [push, pull_request]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v6
        with:
          distribution: temurin
          java-version: "21"
          cache: maven
      - run: mvn -B verify
```

## Workflow Best Practices

1. **Pin actions to a full commit SHA** with a version comment (`@<sha> # v7.0.1`, as in Pattern 1); tags can be moved. Let Dependabot update the SHAs
2. **Cache dependencies** to speed up builds
3. **Use secrets** for sensitive data
4. **Implement status checks** on PRs
5. **Use matrix builds** for multi-version testing
6. **Read-only token by default**: top-level `permissions: contents: read`, widen per job (`packages: write`, `id-token: write`, `security-events: write`)
7. **Use reusable workflows** for common patterns
8. **Gate production** with `environment: production` and required reviewers; use OIDC, not long-lived cloud keys
9. **Add notification steps** for failures
10. **Use self-hosted runners** for sensitive workloads, only in private repos (never for fork PRs)

## Reusable Workflows

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string
    secrets:
      NPM_TOKEN:
        required: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
      - run: npm test
```

**Use reusable workflow:**

```yaml
jobs:
  call-test:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: "20.x"
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Security Scanning

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  security:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write # needed to upload SARIF

    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@0.28.0
        with:
          scan-type: "fs"
          scan-ref: "."
          format: "sarif"
          output: "trivy-results.sarif"

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: "trivy-results.sarif"

      - name: Run Snyk Security Scan
        uses: snyk/actions/node@0.4.0
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## Deployment with Approvals

```yaml
name: Deploy to Production

on:
  push:
    tags: ["v*"]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://app.example.com

    steps:
      - uses: actions/checkout@v4

      - name: Deploy application
        run: |
          echo "Deploying to production..."
          # Deployment commands here
```


## Related Skills

- `deployment-pipeline-design` - For pipeline architecture
