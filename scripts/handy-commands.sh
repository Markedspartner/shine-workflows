docker build -t shinekubernetesclusterregistry.azurecr.io/image-workflow-1741179359433:latest .

docker tag image-workflow-1741179359433:latest shinekubernetesclusterregistry.azurecr.io/image-workflow-1741179359433:latest

docker push shinekubernetesclusterregistry.azurecr.io/image-workflow-1741179359433:latest
