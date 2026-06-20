#!/usr/bin/env bash

function convert_video_uid0017() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0017.mp4"

    function fps_ceil() {
        local fps_max="30"
        local fps_original

        fps_original="$(ffprobe \
            -v error \
            -select_streams v:0 \
            -show_entries "stream=avg_frame_rate" \
            -of csv=p=0 \
            "$1" | awk -F '/' '{ if ($2) print $1 / $2; else print $1 }')"
        fps_original="${fps_original:-"$fps_max"}"

        awk -v fps="$fps_original" -v max="$fps_max" \
            'BEGIN { if (fps > max) print max; else print fps }'
    }

    local fps
    fps="$(fps_ceil "$input_file")"

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
        -r:v "$fps"
        -c:a aac
        -ar:a 22050
    )

    ffmpeg \
    	-i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0017
