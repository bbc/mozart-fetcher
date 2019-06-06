#!/bin/bash

NAME=`cat /etc/bake-scripts/config.json | python -c 'import sys, json; print json.load(sys.stdin)["name"]'`
ENVIRONMENT=`cat /etc/bake-scripts/config.json | python -c 'import sys, json; print json.load(sys.stdin)["environment"]'`
AWS_REGION=`cat /etc/bake-scripts/config.json | python -c 'import sys, json; print json.load(sys.stdin)["configuration"]["aws_region"]'`

cat > /etc/statsd.conf <<EOF
{
    backends: ["/usr/share/bbc-statsd-cloudwatch/cloudwatch-backend.js"],
    cloudWatch: {
      region: "${AWS_REGION}",
      bbcApp: "${NAME}",
      bbcEnvironment: "${ENVIRONMENT}"
    },
    flushInterval: 60000
}
EOF
