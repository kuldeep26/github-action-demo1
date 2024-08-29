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
# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <aws_region> <ecr_repository_url> <namespace>"
    exit 1
fi

# Assign arguments to variables
aws_region="$1"
ecr_repository_url="$2"
namespace="$(echo "$3" | tr -d '')"

# Define secret name
secret_name="ecr-registry-secret"

# Fetch ECR password
echo "Fetching ECR password"
ecr_password=$(aws ecr get-login-password --region "$aws_region")

# Check if the secret already exists
if kubectl get secret "$secret_name" --namespace "$namespace" > /dev/null 2>&1; then
    echo "Secret '$secret_name' already exists in namespace '$namespace'. Skipping creation."
else
    echo "Creating Kubernetes secret"
    kubectl create secret docker-registry "$secret_name" \
        --docker-server="$ecr_repository_url" \
        --docker-username=AWS \
        --docker-password="$ecr_password" \
        --namespace "$namespace"
    echo "Secret '$secret_name' created successfully in namespace '$namespace'."
fi