#!/usr/bin/env bash

# EDGE CASE: Player is unable to begin playback for files <25KB.
function convert_video_uid0016() {
    [[ -z "$1" ]] && return 1

    local input_file="$1"
    local output_file="${2:-"${input_file%.*}.uid0016.mp4"}"

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
        -n
        -f mp4
        -map 0:v:0
        -map 0:a:0?
        -c:v libx264
        -filter:v
        "
            transpose=cclock:passthrough=landscape,
            scale=$size:force_original_aspect_ratio=increase:flags=area:out_range=tv,
            crop=$size
        "
        -sws_flags "accurate_rnd+full_chroma_int+full_chroma_inp"
        -pix_fmt:v yuv420p
        -crf:v 29
        -r:v "$fps"
        -c:a aac
        -ar:a 16000
        -ac:a 1
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0016

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_video_uid0016 "$@"