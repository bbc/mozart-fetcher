#!/bin/bash

# Exit on any error
set -e

# Create environment file
ENV_FILE="/etc/mozart-fetcher/environment"

# Add environment
ENV=$(cat "$BAKE_METADATA/environment")
echo "ENVIRONMENT=$ENV" >> "$ENV_FILE"

# Add service name
SERVICE_NAME=$(cat "$BAKE_METADATA/service_name")
echo "SERVICE_NAME=$SERVICE_NAME" >> "$ENV_FILE"

# Add region
REGION=$(cat "$BAKE_METADATA/configuration/aws_region")
echo "REGION=$REGION" >> "$ENV_FILE"

# Add stack id
ENV=$(cat "$BAKE_METADATA/environment")
echo "STACKID=$ENV-$SERVICE_NAME-main" >> "$ENV_FILE"

echo "Environment file created at $ENV_FILE"