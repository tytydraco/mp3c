#!/usr/bin/env bash

function convert_video_generic_mp4() {
    [[ -z "${1:-}" ]] && return 1

    local name="${NAME:-generic}"
    local width="${WIDTH:-1920}"
    local height="${HEIGHT:-1080}"
    local maxfps="${MAXFPS:-30}"

    local input_file="$1"
    local output_file="${input_file%.*}.${name}_${width}x${height}.mp4"

    local size="'if(gt(ih, iw), -2, min($width, iw))':'if(gt(ih, iw), min($height, ih), -2)'"
    local ffmpeg_args=(
        -n                                                                                  # Do not replace existing files.
        -f mp4                                                                              # MP4 container.
        -map 0:v:0                                                                          # Choose first video stream.
        -map 0:a:0?                                                                         # Choose first audio stream, if it exists.
        -c:v libx264                                                                        # H.264 codec.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease:force_divisible_by=2"   # Contain within size, preserve aspect ratio, ensure even lengths.
        -pix_fmt:v yuv420p                                                                  # yuv420p pixel format.
        -fpsmax:v "$maxfps"                                                                 # Limit FPS.
        -c:a aac                                                                            # AAC audio codec.
        -profile:a aac_low                                                                  # AAC low profile.
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_generic_mp4