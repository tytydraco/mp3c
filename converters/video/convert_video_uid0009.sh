#!/usr/bin/env bash

function convert_video_uid0009() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0009.amv"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    # Return the closest allowed ceiling frame rate for a video file.
    function fps_ceil() {
        local -a fps_allowed
        local fps_max
        local fps_original
        local fps_nearest

        # Find valid FPS within [9, 30].
        readarray -t fps_allowed < <(seq 9 30 | awk '22050 % $1 == 0 { print $1 }')
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

    local size="'if(gt(iw, ih), 320, 240)':'if(gt(iw, ih), 240, 320)'"
    local ffmpeg_args=(
        -n                                                                                                                                  # Do not replace existing files.
        -f amv                                                                                                                              # AMV container.
        -c:v amv                                                                                                                            # AMV codec.
        -filter:v "scale=$size:force_original_aspect_ratio=increase,crop=$size:(iw-ow)/2:(ih-oh)/2,transpose=cclock:passthrough=landscape"  # Contain within size, preserve aspect ratio, crop, pre-rotate counter-clockwise (landscape bypass).
        -r:v "$fps"                                                                                                                         # Closest allowed ceiling frame rate.
        -block_size:a "$block_size"                                                                                                         # Corresponding audio block size.
    )

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0                                                                                                                      # Choose first video stream.
            -map 0:a:0                                                                                                                      # Choose first audio stream.
        )
    else
        ffmpeg_map_args=(
            -f lavfi                                                                                                                        # Virtual audio device.
            -i "anullsrc=channel_layout=mono:sample_rate=22050"                                                                             # 22.05 kHz silent audio (minimum).
            -map 0:v:0                                                                                                                      # Choose first video stream.
            -map 1:a                                                                                                                        # Include silent audio.
            -shortest                                                                                                                       # Stop encoding when video stream ends.
        )
    fi

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0009