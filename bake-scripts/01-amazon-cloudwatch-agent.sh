#!/bin/bash

COMPONENT_NAME=$(cat $BAKE_METADATA/service_name)
ENVIRONMENT=$(cat $BAKE_METADATA/environment)

cat > /etc/cloudwatch-agent-config.json <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "namespace": "BBCApp/$COMPONENT_NAME",
    "metrics_collected": {
      "statsd": {
        "service_address": ":8125",
        "metric_separator": ".",
        "metrics_collection_interval": 60,
        "metrics_aggregation_interval": 60
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait"
        ],
        "append_dimensions": {
          "BBCEnvironment": "$ENVIRONMENT"
        }
      },
      "disk": {
        "resources": [
          "/"
        ],
        "measurement": [
          "disk_used_percent"
        ],
        "append_dimensions": {
          "BBCEnvironment": "$ENVIRONMENT"
        }
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "append_dimensions": {
          "BBCEnvironment": "$ENVIRONMENT"
        }
      },
      "processes": {
        "measurement": [
          "running",
          "sleeping",
          "dead"
        ],
        "append_dimensions": {
          "BBCEnvironment": "$ENVIRONMENT"
        }
      },
      "net": {
        "measurement": [
          "packets_recv",
          "packets_sent"
        ],
        "append_dimensions": {
          "BBCEnvironment": "$ENVIRONMENT"
        }
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_syn_sent",
          "tcp_close"
        ],
        "append_dimensions": {
          "BBCEnvironment": "$ENVIRONMENT"
        },
        "metrics_collection_interval": 60
      }
    },
    "aggregation_dimensions" : [
      ["BBCEnvironment"],
      ["component_id"],
      ["component_id", "status_code"],
      ["status_code"]
    ]
  }
}
EOF

cat > /etc/systemd/system/start-cloudwatch-agent.service <<EOF
[Unit]
Description=Start the amazon cloudwatch agent service
After=network.target network-online.target
[Service]
ExecStart=/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/etc/cloudwatch-agent-config.json -s
[Install]
WantedBy=multi-user.target
EOF

systemctl enable start-cloudwatch-agent
