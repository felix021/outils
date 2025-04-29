#!/bin/bash

function urlencode() {
	python3 -c "import urllib.parse; print(urllib.parse.quote(\"$*\"), end=\"\")"
}