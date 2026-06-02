#!/usr/bin/env bash

# Experimental reverse-engineered ATJ MJPEG AVI.
function convert_video_uid0005_experimental() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0005.avi"

    SOURCE="$input_file" OUT="$output_file" "$ATJ_AVI_ENCODER"
}

export -f convert_video_uid0005_experimental