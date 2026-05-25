#!/usr/bin/env bash

function convert_video_agptek_m6_avi() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.agptek_m6.avi"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    local fps=30
    local size="'if(gt(ih, iw), 240, 320)':'if(gt(ih, iw), 320, 240)'"
    local ffmpeg_args=(
        -n                                                                                                                                  # Do not replace existing files.
        -f avi                                                                                                                              # AVI container.
        -c:v libx264                                                                                                                        # H.264 codec.
        -profile:v baseline                                                                                                                 # H.264 baseline profile.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease,pad=$size:(ow-iw)/2:(oh-ih)/2:black,transpose=2:passthrough=portrait"   # Contain within 240x320, preserve aspect ratio, pad, pre-rotate (portrait bypass).
        -pix_fmt:v yuv420p                                                                                                                  # yuv420p pixel format.
        -bufsize:v 2M                                                                                                                       # Hardware buffer size of 2 Mb.
        -maxrate:v 2M                                                                                                                       # Limit bitrate to 2 Mbps.
        -g:v "$fps"                                                                                                                         # GOP length every 1 second.
        -b:v 1M                                                                                                                             # Target average bitrate of 1 Mbps.
        -fpsmax:v "$fps"                                                                                                                    # Limit FPS.
        -c:a pcm_s16le                                                                                                                      # 16-bit PCM audio codec.
        -ac:a 1                                                                                                                             # Mono audio.
    )

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0                                                                                                                      #  Choose first video stream.
            -map 0:a:0                                                                                                                      #  Choose first audio stream.
            -ar:a 22050                                                                                                                     # 22.05 kHz audio rate.
        )
    else
        ffmpeg_map_args=(
            -f lavfi                                                                                                                        # Virtual audio device.
            -i "anullsrc=channel_layout=mono:sample_rate=8000"                                                                              # 8 kHz silent audio.
            -map 0:v:0                                                                                                                      # Choose first video stream.
            -map 1:a                                                                                                                        # Include silent audio.
            -ar:a 8000                                                                                                                      # 8 kHz audio rate.
            -shortest                                                                                                                       # Stop encoding when video stream ends.
        )
    fi

    
    WINEDEBUG=-all wine converters/ffmpeg-mod.exe \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_agptek_m6_avi