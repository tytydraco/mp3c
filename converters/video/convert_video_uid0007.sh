#!/usr/bin/env bash

function convert_video_uid0007() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0007.avi"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

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

    local size="128:160"
    local ffmpeg_args=(
        -n
        -f avi
        -c:v mjpeg
        -filter:v
        "
            transpose=clock:passthrough=portrait,
            scale=$size:force_original_aspect_ratio=increase,
            crop=$size,
            vflip
        "
        -pix_fmt:v yuvj420p
        -r:v "$fps"
        -q:v 4
        -c:a pcm_s16le
        -ac:a 2
    )

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0
            -map 0:a:0
            -ar:a 22050
        )
    else
        ffmpeg_map_args=(
            -f lavfi
            -i "anullsrc=channel_layout=stereo:sample_rate=8000"
            -map 0:v:0
            -map 1:a
            -ar:a 8000
            -shortest
        )
    fi

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0007
