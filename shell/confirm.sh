#!/bin/bash

function confirm() {
	echo $* > /dev/stderr
	char=`head -c 8 /dev/urandom | md5sum | head -c 1`
	read -n 1 -p "输入 `yellow_bg ${char}` 确认，任意键取消: " x
	echo > /dev/stderr
	if [ "$x" != "$char" ]; then
		echo -e "\n已取消.\n" > /dev/stderr
		exit 1;
	fi
	echo -e "已确认\n" > /dev/stderr
}