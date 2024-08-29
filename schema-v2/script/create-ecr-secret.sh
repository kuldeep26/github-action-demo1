#!/bin/bash

aws_region=$1
ecr_repository_url=$2
namespace=$3

echo "Fetching ECR password"
ecr_password=$(aws ecr get-login-password --region ${aws_region})

echo "Creating Kubernetes secret"
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=${ecr_repository_url} \
  --docker-username=AWS \
  --docker-password="${ecr_password}" \
  --namespace ${namespace}