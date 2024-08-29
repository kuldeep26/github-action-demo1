#!/bin/bash

RDS_INSTANCE_NAME=$1

echo "Starting script..."

# Fetch the RDS master user secret ARN
SECRET_ARN=$(aws rds describe-db-instances --db-instance-identifier $RDS_INSTANCE_NAME --query "DBInstances[0].MasterUserSecret.SecretArn" --output text)
echo "Fetched Secret ARN: $SECRET_ARN"

# Extract the secret name from the ARN
SECRET_NAME=$(echo $SECRET_ARN | awk -F'/' '{print $NF}')
echo "Extracted Secret Name: $SECRET_NAME"

# Fetch the secret details using the extracted secret name
SECRET_NAME_FROM_AWS=$(aws secretsmanager describe-secret --secret-id $SECRET_NAME --query "Name" --output text)
if [ $? -ne 0 ]; then
    echo "Error fetching secret details."
    exit 1
fi

# Export the secret name as an environment variable
export RDS_SECRET_NAME=$SECRET_NAME_FROM_AWS
echo "RDS Secret Name set as environment variable: $RDS_SECRET_NAME"
