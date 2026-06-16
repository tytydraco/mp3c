#!/usr/bin/env bash

function convert_video_uid0001() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0001.avi"

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

    local size="'if(gt(iw, ih), 288, 240)':'if(gt(iw, ih), 240, 288)'"
    local ffmpeg_args=(
        -n
        -f avi
        -c:v libx264
        -x264-params "mvrange=16:merange=16"
        -profile:v baseline
        -filter:v
        "
            scale=$size:force_original_aspect_ratio=increase,
            crop=$size:(iw-ow)/2:(ih-oh)/2,
            transpose=cclock:passthrough=portrait
        "
        -bsf:v "filter_units=remove_types=6"
        -pix_fmt:v yuvj420p
        -r:v "$fps"
        -g:v 10
        -qmin:v 20
        -sc_threshold:v 0
        -c:a pcm_s16le
        -ac:a 1
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
            -i "anullsrc=channel_layout=mono:sample_rate=8000"
            -map 0:v:0
            -map 1:a
            -ar:a 8000
            -shortest
        )
    fi

    "$FFMPEG_YP3" \
    	-i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0001
