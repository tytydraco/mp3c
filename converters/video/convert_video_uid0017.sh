#!/usr/bin/env bash

function convert_video_uid0017() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0017.mp4"

    local size="'if(gt(iw, ih), 160, 128)':'if(gt(iw, ih), 128, 160)'"
    local ffmpeg_args=(
        -n
        -f mp4
        -map 0:v:0
        -map 0:a:0?
        -c:v libxvid
        -filter:v
        "
            scale=$size:force_original_aspect_ratio=increase,
            crop=$size:(iw-ow)/2:(ih-oh)/2,
            transpose=cclock:passthrough=landscape
        "
        -q:v 4
        -c:a aac
    )

    ffmpeg \
    	-i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0017
