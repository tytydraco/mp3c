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

    local size="'if(gt(ih, iw), 240, 288)':'if(gt(ih, iw), 288, 240)'"
    local ffmpeg_args=( 
        -n                                                                                                                                      # Do not replace existing files.
        -f avi                                                                                                                                  # AVI container.
        -c:v libx264                                                                                                                            # H.264 codec.
        -x264-params "mvrange=16:merange=16"                                                                                                    # Clamp motion-vector range.
        -profile:v baseline                                                                                                                     # H.264 baseline profile.
        -filter:v "scale=$size:force_original_aspect_ratio=increase,crop=$size:(iw-ow)/2:(ih-oh)/2,transpose=cclock:passthrough=portrait"       # Contain within size, preserve aspect ratio, crop, pre-rotate counter-clockwise (portrait bypass).
        -bsf:v "filter_units=remove_types=6"                                                                                                    # Remove SEI.
        -pix_fmt:v yuvj420p                                                                                                                     # Full range pixel format.
        -crf:v 20                                                                                                                               # Target consistent quality.
        -r:v "$fps"                                                                                                                             # Match original source FPS.
        -g:v 10                                                                                                                                 # Short GOP for better disposable P-frame prediction.
        -qmin:v 20                                                                                                                              # Limit I-frame complexity.                                                                                                                   # Disable scene-cut.
        -sc_threshold:v 0                                                                                                                       # Disable scene-cut insertions.
        -c:a pcm_s16le                                                                                                                          # 16-bit PCM audio codec.
        -ac:a 1                                                                                                                                 # Mono audio.
    )

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0                                                                                                                          # Choose first video stream.
            -map 0:a:0                                                                                                                          # Choose first audio stream.
            -ar:a 22050                                                                                                                         # 22.05 kHz audio rate.
        )
    else
        ffmpeg_map_args=(
            -f lavfi                                                                                                                            # Virtual audio device.
            -i "anullsrc=channel_layout=mono:sample_rate=8000"                                                                                  # 8 kHz silent audio.
            -map 0:v:0                                                                                                                          # Choose first video stream.
            -map 1:a                                                                                                                            # Include silent audio.
            -ar:a 8000                                                                                                                          # 8 kHz audio rate.
            -shortest                                                                                                                           # Stop encoding when video stream ends.
        )
    fi

    "$FFMPEG_YP3" \
    	-i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0001