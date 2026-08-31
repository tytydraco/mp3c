#!/usr/bin/env bash

function convert_video_uid0018() {
    [[ -z "$1" ]] && return 1

    local input_file="$1"
    local output_file="${2:-"${input_file%.*}.uid0018.mp4"}"

    function fps_ceil() {
        local fps_max="25"
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

    local size="320:240"
    local ffmpeg_args=(
        -f mp4
        -map 0:v:0
        -map 0:a:0?
        -c:v mpeg4
        -filter:v
        "
            transpose=cclock:passthrough=landscape,
            scale=$size:force_original_aspect_ratio=increase:flags=area:out_range=tv,
            crop=$size
        "
        -sws_flags "accurate_rnd+full_chroma_int+full_chroma_inp"
        -pix_fmt:v yuv420p
        -b:v 250k
        -g:v "$fps"
        -r:v "$fps"
        -c:a aac
        -ac:a 1
        -ar:a 16000
    )

    local passlog_dir
    passlog_dir="$(mktemp -d)"
    local passlog="$passlog_dir/log"
    ffmpeg \
        -nostdin \
        -n \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        -pass 1 \
        -passlogfile "$passlog" \
        -an \
        -f null \
        /dev/null
    ffmpeg \
        -nostdin \
        -n \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        -pass 2 \
        -passlogfile "$passlog" \
        "$output_file"
    rm -rf "$passlog_dir"
    MP4Box \
        -inter 1 \
        -tmp "$(dirname -- "$output_file")" \
        "$output_file"
}

export -f convert_video_uid0018

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_video_uid0018 "$@"