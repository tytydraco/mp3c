#!/usr/bin/env bash

FFMPEG_MOD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/ffmpeg-mod.exe"

function convert_video_240x288_h264_pcms16le_avi() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.240x288_h264_pcms16le.avi"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    local size="'if(gt(ih, iw), 240, 288)':'if(gt(ih, iw), 288, 240)'"
    local ffmpeg_args=(
        -n                                                                                                                                      # Do not replace existing files.
        -f avi                                                                                                                                  # AVI container.
        -c:v libx264                                                                                                                            # H.264 codec.
        -profile:v baseline                                                                                                                     # H.264 baseline profile.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease,pad=$size:(ow-iw)/2:(oh-ih)/2:black,transpose=cclock:passthrough=portrait"  # Contain within size, preserve aspect ratio, pad, pre-rotate counter-clockwise (portrait bypass).
        -pix_fmt:v yuvj420p                                                                                                                     # Full range pixel format.
        -bufsize:v 2M                                                                                                                           # Hardware buffer size.
        -maxrate:v 2M                                                                                                                           # Limit bitrate.
        -b:v 1M                                                                                                                                 # Target average bitrate.
        -fpsmax:v 30                                                                                                                            # Limit FPS.
        -g:v 30                                                                                                                                 # GOP length every 1 second.
        -qmin:v 18                                                                                                                              # Limit maximum I-frame complexity.
        -c:a pcm_s16le                                                                                                                          # 16-bit PCM audio codec.
        -ac:a 2                                                                                                                                 # Stereo audio.
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

    WINEDEBUG=-all wine "$FFMPEG_MOD" \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export FFMPEG_MOD
export -f convert_video_240x288_h264_pcms16le_avi