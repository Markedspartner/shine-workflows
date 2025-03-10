#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [major|minor|patch]"
  exit 1
fi

INCREMENT_TYPE=$1
VERSION_FILE="./VERSION"

# Initialize version if file not found
if [ ! -f "$VERSION_FILE" ]; then
  echo "0.0.0" > "$VERSION_FILE"
fi

current_version=$(cat "$VERSION_FILE")
IFS='.' read -r major minor patch <<< "$current_version"

case "$INCREMENT_TYPE" in
  major)
    major=$((major + 1)); minor=0; patch=0;;
  minor)
    minor=$((minor + 1)); patch=0;;
  patch)
    patch=$((patch + 1));;
  *)
    echo "Invalid type. Use major, minor, or patch." && exit 1;;
esac

new_version="${major}.${minor}.${patch}"
echo "$new_version" > "$VERSION_FILE"
echo "New version: $new_version"

IMAGE="shinekubernetesclusterregistry.azurecr.io/image-workflow-1741179359433:${new_version}"

echo "Building Docker image $IMAGE for ARM64..."

docker buildx build --platform linux/arm64,linux/amd64 \
	-t "$IMAGE" \
	-f ./docker/images/n8n-custom/Dockerfile \
	--push .

echo "Build and push complete."
