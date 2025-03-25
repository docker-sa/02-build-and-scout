To use a **Git commit hash** instead of a version number in a GitHub Action like `docker/setup-buildx-action@v3`, you can replace the version tag with the full commit SHA of the desired commit.

### ✅ Example

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@<commit-sha>
```

Replace `<commit-sha>` with the actual commit hash from the [repository](https://github.com/docker/setup-buildx-action).

### 🔍 How to find the commit SHA
1. Go to the [setup-buildx-action GitHub repo](https://github.com/docker/setup-buildx-action).
2. Click on the **Commits** tab.
3. Copy the **full SHA** (not just the short version) of the commit you want to pin to.

For example:

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@3d4f4cfa40e2b2118c7905fd9a76d8fe9205038c
```

### 🔐 Why use a commit hash?
- **Security**: Pinning to a specific commit avoids potential supply chain risks of a tag being moved.
- **Reproducibility**: Ensures your CI uses the exact same version even if the tag (`@v3`, `@main`, etc.) changes later.
