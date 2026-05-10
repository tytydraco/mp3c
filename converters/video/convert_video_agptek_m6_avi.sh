#!/usr/bin/env bash

function convert_video_agptek_m6_avi() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.agptek_m6.avi"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    wine converters/ffmpeg-mod.exe \
        -i "$input_file" \
        -n \
        -map 0:v:0 \
        -map 0:a:0 \
        -profile:v baseline \
        -x264-params "imax=98304:pmax=65536:ipmax=163840" \
        -f avi \
        -vf "scale=320:240:force_original_aspect_ratio=decrease,pad=320:240:(ow-iw)/2:(oh-ih)/2:black,transpose=2" \
        -strict -1 \
        -c:v libx264 \
        -c:a pcm_s16le \
        -pix_fmt yuv420p \
        -refs 1 \
        -g 7 \
        -vb 1500000 \
        -ac 1 \
        -ar 16000 \
        -r 30 \
        "$output_file"
}

export -f convert_video_agptek_m6_avi