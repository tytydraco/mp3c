#!/usr/bin/env bash

function convert_video_uid0008() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0008.mp4"

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

    local size="'if(gte(iw/ih, 4/3), -2, min(640, iw))':'if(gte(iw/ih, 4/3), min(480, ih), -2)'"
    local crop="'min(640, iw)':'min(480, ih)'"
    local ffmpeg_args=(
        -n
        -f mp4
        -map 0:v:0
        -map 0:a:0?
        -c:v libx264
        -filter:v
        "
            transpose=cclock:passthrough=landscape,
            scale=$size:force_divisible_by=2:in_range=auto:out_range=tv,
            crop=$crop
        "
        -pix_fmt:v yuv420p
        -crf:v 36
        -r:v "$fps"
        -c:a aac
        -ar:a 22050
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0008
