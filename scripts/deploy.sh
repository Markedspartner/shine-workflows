#!/bin/bash
set -e

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 [prod|dev|local] [optional: image tag]"
  exit 1
fi

DEPLOY_ENV=$1

if [ "$#" -eq 2 ]; then
  IMAGE_TAG=$2
else
  if [ ! -f "./VERSION" ]; then
    echo "VERSION file not found. Provide an image tag."
    exit 1
  fi
  IMAGE_TAG=$(cat "./VERSION")
fi

IMAGE="shinekubernetesclusterregistry.azurecr.io/image-workflow-1741179359433:${IMAGE_TAG}"
echo "Deploying image $IMAGE to $DEPLOY_ENV..."

case "$DEPLOY_ENV" in
  local)
    echo "Running local deployment..."
    docker run --rm -d -p 5678:5678 "$IMAGE"
    ;;
  dev)
    echo "Authenticating with Azure dev cluster..."
    az aks get-credentials --resource-group shine-common --name shine-kubernetes-cluster-dev
    echo "Applying Kubernetes manifests for dev..."
    kubectl apply -f ./manifests --namespace=shine-workflows
    ;;
  prod)
    echo "Authenticating with Azure prod cluster..."
    az aks get-credentials --resource-group shine-common --name shine-kubernetes-cluster
    echo "Applying Kubernetes manifests for prod..."
    kubectl apply -f ./k8s --namespace=shine-workflows
    ;;
  *)
    echo "Invalid environment. Use prod, dev, or local."
    exit 1
    ;;
esac

echo "Deployment complete."
