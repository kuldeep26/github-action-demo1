#!/bin/bash

# Assign arguments to variables
# aws_region="$1"
# ecr_repository_url="$2"
# namespace="$(echo "$3" | tr -d '')"

# echo "Fetching ECR password"
# ecr_password=$(aws ecr get-login-password --region "$aws_region")

# echo "Creating Kubernetes secret"
# kubectl create secret docker-registry ecr-registry-secret --docker-server="$ecr_repository_url" --docker-username=AWS --docker-password="$ecr_password" --namespace "$namespace"

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <aws_region> <ecr_repository_url> <namespace>"
    exit 1
fi

aws_region="$1"
ecr_repository_url="$2"
namespace="$(echo "$3" | tr -d '')"

echo "Fetching ECR password"
ecr_password=$(aws ecr get-login-password --region "$aws_region")

echo "Creating Kubernetes secret"
kubectl create secret docker-registry ecr-registry-secret --docker-server="$ecr_repository_url" --docker-username=AWS --docker-password="$ecr_password" --namespace "$namespace"