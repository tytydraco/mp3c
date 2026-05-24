#!/usr/bin/env bash

function convert_video_ruizu_x52_amv() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.ruizu_x52.amv"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries stream=index \
            -of csv=p=0 \
            "$1" | grep -q .
    }

    local audio_sample_rate=22050
    local ffmpeg_args=(
        -n
        -preset:v superfast
        -f amv
        -vf "scale=128:128:force_original_aspect_ratio=decrease"
        -strict -1
        -c:v amv
        -c:a adpcm_ima_amv
        -ac 1
        -ar "$audio_sample_rate"
        -r 30
        -block_size 735
    )

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0
            -map 0:a:0
        )
    else
        ffmpeg_map_args=(
            -f lavfi 
            -i "anullsrc=channel_layout=mono:sample_rate=$audio_sample_rate"
            -map 0:v:0
            -map 1:a
            -shortest
        )
    fi

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_ruizu_x52_amv