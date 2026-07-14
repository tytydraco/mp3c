#!/usr/bin/env bash

function convert_video_uid0004() {
    [[ -z "$1" ]] && return 1

    local input_file="$1"
    local output_file="${2:-"${input_file%.*}.uid0004.avi"}"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

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

    local size="240:320"
    local ffmpeg_args=(
        -n
        -f avi
        -c:v libx264
        -x264-params "mbtree=0:rc-lookahead=0:aq-mode=0:me=tesa:subme=11"
        -profile:v baseline
        -filter:v
        "
            transpose=cclock:passthrough=portrait,
            scale=$size:force_original_aspect_ratio=increase,
            crop=$size
        "
        -sws_flags "accurate_rnd+full_chroma_int+full_chroma_inp"
        -maxrate 10M
        -bufsize 3M
        -pix_fmt:v yuvj420p
        -r:v "$fps"
        -crf:v 29
        -qmin:v 10
        -g:v 6
        -sc_threshold:v 0
        -refs:v 1
        -c:a pcm_s16le
        -ac:a 1
        -ar:a 16000
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
            -i "anullsrc=channel_layout=mono:sample_rate=16000"
            -map 0:v:0
            -map 1:a
            -shortest
        )
    fi

    "$FFMPEG_YP3" \
    	-i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0004

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_video_uid0004 "$@"
