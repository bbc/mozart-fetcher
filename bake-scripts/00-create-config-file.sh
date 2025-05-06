#!/bin/bash

# Exit on any error
set -e

CONFIG_JSON="/etc/mozart-fetcher/config.json"

# Start building the JSON
echo "{" > "$CONFIG_JSON"

# Get service name and region
SERVICE_NAME=$(cat "$BAKE_METADATA/service_name")
REGION=$(cat "$BAKE_METADATA/configuration/aws_region")

# Start configuration object
echo "  \"configuration\": {" >> "$CONFIG_JSON"

# Process all configuration files
CONFIG_COUNT=$(find "$BAKE_METADATA/configuration" -type f | wc -l)
CURRENT=0
for config_file in $(find "$BAKE_METADATA/configuration" -type f | sort); do
    if [ -f "$config_file" ]; then
        CURRENT=$((CURRENT + 1))
        KEY=$(basename "$config_file")
        VALUE=$(cat "$config_file")
        # Escape any double quotes in the value for nested JSON
        VALUE=$(echo "$VALUE" | sed 's/"/\\"/g')

        # Add comma for all but the last item
        if [ $CURRENT -lt $CONFIG_COUNT ]; then
            echo "    \"$KEY\": \"$VALUE\"," >> "$CONFIG_JSON"
        else
            echo "    \"$KEY\": \"$VALUE\"" >> "$CONFIG_JSON"
        fi
    fi
done

# Close configuration object
echo "  }," >> "$CONFIG_JSON"

# Add environment
ENV=$(cat "$BAKE_METADATA/environment")
echo "  \"environment\": \"$ENV\"," >> "$CONFIG_JSON"

# Add external_dependencies (empty object)
echo "  \"external_dependencies\": {}," >> "$CONFIG_JSON"

# Add name
echo "  \"name\": \"$SERVICE_NAME\"," >> "$CONFIG_JSON"

# Add release version
VERSION=$(cat "$BAKE_METADATA/release_version")
echo "  \"release\": \"$VERSION\"," >> "$CONFIG_JSON"

# Add resources (empty object)
echo "  \"resources\": {}," >> "$CONFIG_JSON"
echo "  \"secure_configuration\": {}" >> "$CONFIG_JSON"
echo "}" >> "$CONFIG_JSON"

# cat and echo the JSON file
echo "Configuration JSON created at $CONFIG_JSON"