#!/usr/bin/env bash

function convert_video_uid0005() {
    [[ -z "$1" ]] && return 1

    local input_file="$1"
    local output_file="${2:-"${input_file%.*}.uid0005.amv"}"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    function fps_ceil() {
        local -a fps_allowed
        local fps_max
        local fps_original
        local fps_nearest

        # Find valid FPS within [9, 25].
        readarray -t fps_allowed < <(seq 9 25 | awk '22050 % $1 == 0 { print $1 }')
        fps_max="${fps_allowed[-1]}"

        fps_original="$(ffprobe \
            -v error \
            -select_streams v:0 \
            -show_entries "stream=avg_frame_rate" \
            -of csv=p=0 \
            "$1" | awk -F '/' '{ if ($2) print $1 / $2; else print $1 }')"
        fps_nearest="$(printf \
            "%s\n" \
            "${fps_allowed[@]}" | awk \
                -v fps="$fps_original" \
                '$1 >= fps { print $1; exit }')"

        echo "${fps_nearest:-"$fps_max"}"
    }

    local fps
    local block_size

    fps="$(fps_ceil "$input_file")"
    block_size="$((22050 / fps))"

    local size="128:128"
    local ffmpeg_args=(
        -n
        -f amv
        -c:v amv
        -filter:v
        "
            scale=$size:force_original_aspect_ratio=increase,
            crop=$size
        "
        -r:v "$fps"
        -block_size:a "$block_size"
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
            -i "anullsrc=channel_layout=mono:sample_rate=22050"
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

export -f convert_video_uid0005
