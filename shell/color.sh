#!/bin/bash

function color_red() {
	color 31 $*
}

function color_green() {
	color 32 $*
}

function yellow_bg() {
	color '97;43' $*
}

function color_red_bg_yellow() {
	color '31;43' $*
}

function color() {
	scheme=$1
	shift
	echo -ne "\e[${scheme}m"$*"\e[0m"
}
