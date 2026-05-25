#!/usr/bin/env bash

function convert_video_1080p_mp4() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.1080p.mp4"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    local size="'if(gt(ih, iw), -2, min(1920, iw))':'if(gt(ih, iw), min(1920, ih), -2)'"
    local ffmpeg_args=(
        -n                                                                                  # Do not replace existing files.
        -f mp4                                                                              # MP4 container.
        -map 0:v:0                                                                          # Choose first video stream.
        -map 0:a:0?                                                                         # Choose first audio stream, if it exists.
        -c:v libx264                                                                        # H.264 codec.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease:force_divisible_by=2"   # Contain within max length of 1920 px, preserve aspect ratio, ensure even lengths.
        -pix_fmt:v yuv420p                                                                  # yuv420p pixel format.
        -fpsmax:v 60                                                                        # 60 fps maximum.
        -c:a aac                                                                            # AAC audio codec.
        -profile:a aac_low                                                                  # AAC low profile.
    )
    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_1080p_mp4