#!/usr/bin/env bash

function convert_video_generic_avi() {
    [[ -z "${1:-}" ]] && return 1

    local name="${NAME:-generic}"
    local width="${WIDTH:-240}"
    local height="${HEIGHT:-320}"
    local maxfps="${MAXFPS:-30}"
    local bitrate="${BITRATE:-1M}"
    local bufsize="${BUFSIZE:-2M}"
    local maxrate="${MAXRATE:-2M}"

    local input_file="$1"
    local output_file="${input_file%.*}.${name}_${width}x${height}.avi"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    local size="'if(gt(ih, iw), $width, $height)':'if(gt(ih, iw), $height, $width)'"
    local ffmpeg_args=(
        -n                                                                                                                                  # Do not replace existing files.
        -f avi                                                                                                                              # AVI container.
        -c:v libx264                                                                                                                        # H.264 codec.
        -profile:v baseline                                                                                                                 # H.264 baseline profile.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease,pad=$size:(ow-iw)/2:(oh-ih)/2:black,transpose=2:passthrough=portrait"   # Contain within size, preserve aspect ratio, pad, pre-rotate (portrait bypass).
        -pix_fmt:v yuv420p                                                                                                                  # yuv420p pixel format.
        -bufsize:v "$bufsize"                                                                                                               # Hardware buffer size.
        -maxrate:v "$maxrate"                                                                                                               # Limit bitrate.
        -g:v "$maxfps"                                                                                                                      # GOP length every 1 second.
        -b:v "$bitrate"                                                                                                                     # Target average bitrate.
        -fpsmax:v "$maxfps"                                                                                                                 # Limit FPS.
        -c:a pcm_s16le                                                                                                                      # 16-bit PCM audio codec.
        -ac:a 1                                                                                                                             # Mono audio.
    )

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0                                                                                                                      # Choose first video stream.
            -map 0:a:0                                                                                                                      # Choose first audio stream.
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

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    WINEDEBUG=-all wine "$script_dir/ffmpeg-mod.exe" \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_generic_avi