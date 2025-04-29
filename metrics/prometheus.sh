#!/bin/bash

# Usage:
#   push_gateway $job $instance 'metrics_name{tag_key="tag_value"} 1'

if [ -z "$PUSH_GATEWAY_HOST" ]; then
	echo "PUSH_GATEWAY_HOST is empty"
	exit 1
fi

function push_gateway() {
	job=${1}
	instance=${2}
	metrics=${3}
	curl --data-binary @- $PUSH_GATEWAY_HOST/metrics/job/$job/instance/$instance <<EOT
$metrics
EOT
}

function push_gateway_delete() {
	job=${1}
	instance=${2}
	curl -X DELETE $PUSH_GATEWAY_HOST/metrics/job/$job/instance/$instance
}