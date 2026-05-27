#!/usr/bin/env bash

FFMPEG_MOD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/ffmpeg-mod.exe"

function convert_video_128x160_mjpeg_pcms16le_avi() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.128x160_mjpeg_pcms16le.avi"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    local size="'if(gt(ih, iw), 128, 160)':'if(gt(ih, iw), 160, 128)'"
    local ffmpeg_args=(
        -n                                                                                                                                              # Do not replace existing files.
        -f avi                                                                                                                                          # AVI container.
        -c:v mjpeg                                                                                                                                      # MJPEG codec.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease,pad=$size:(ow-iw)/2:(oh-ih)/2:black,transpose=cclock:passthrough=portrait,vflip"    # Contain within size, preserve aspect ratio, pad, pre-rotate counter-clockwise (portrait bypass), flip vertically.
        -pix_fmt:v yuvj420p                                                                                                                             # Full range pixel format.
        -fpsmax:v 30                                                                                                                                    # Limit FPS.
        -q:v 2                                                                                                                                          # Target average quality.
        -c:a pcm_s16le                                                                                                                                  # 16-bit PCM audio codec.
        -ac:a 2                                                                                                                                         # Stereo audio.
    )

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0                                                                                                                                  # Choose first video stream.
            -map 0:a:0                                                                                                                                  # Choose first audio stream.
            -ar:a 22050                                                                                                                                 # 22.05 kHz audio rate.
        )
    else
        ffmpeg_map_args=(
            -f lavfi                                                                                                                                    # Virtual audio device.
            -i "anullsrc=channel_layout=mono:sample_rate=16000"                                                                                         # 16 kHz silent audio.
            -map 0:v:0                                                                                                                                  # Choose first video stream.
            -map 1:a                                                                                                                                    # Include silent audio.
            -ar:a 16000                                                                                                                                 # 16 kHz audio rate.
            -shortest                                                                                                                                   # Stop encoding when video stream ends.
        )
    fi

    WINEDEBUG=-all wine "$FFMPEG_MOD" \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export FFMPEG_MOD
export -f convert_video_128x160_mjpeg_pcms16le_avi