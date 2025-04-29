#!/bin/bash

# sudo apt  install jq

function custom_bot() {
	title=$1
	content=$2
	json=`jq -n --arg title "$title" --arg content "$content" '{"msg_type":"post","content":{"post":{"zh_cn":{"title":$title,"content":[[{"tag":"text","text":$content}]]}}}}'`
	if [ ! -z "$3" ]; then
		BOT_URL=$3
	fi
	curl -X POST -H "Content-Type: application/json" -d "$json" \
		$BOT_URL &>/dev/null
}

if [ $# -gt 1 ]; then
	custom_bot $1 $2 $3
fi