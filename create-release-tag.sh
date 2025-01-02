#!/bin/bash
set -o allexport; source release.env; set +o allexport

echo "📦️ Creating release ${TAG}..."
git add .
git commit -m "📦 create release ${TAG}"
git tag ${TAG}
git push origin main ${TAG}
echo "📦️ Release ${TAG} created."
echo "🚢 You can now create a release on GitHub."
