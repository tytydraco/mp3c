#!/usr/bin/env bash

function convert_video_uid0004() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0004.avi"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    local size="'if(gt(ih, iw), 240, 320)':'if(gt(ih, iw), 320, 240)'"
    local ffmpeg_args=( 
        -n                                                                                                                                      # Do not replace existing files.
        -f avi                                                                                                                                  # AVI container.
        -c:v libx264                                                                                                                            # H.264 codec.
        -x264-params "ipratio=1:aq-mode=0:rc-lookahead=0"                                                                                                # Auto-variance AQ for dark scenes.
        -profile:v baseline                                                                                                                     # H.264 baseline profile.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease,pad=$size:(ow-iw)/2:(oh-ih)/2:black,transpose=cclock:passthrough=portrait"  # Contain within size, preserve aspect ratio, pad, pre-rotate counter-clockwise (portrait bypass).
        -bsf:v "filter_units=remove_types=6"                                                                                                    # Remove SEI.
        -pix_fmt:v yuvj420p                                                                                                                     # Full range pixel format.
        -crf:v 16                                                                                                                               # Target consistent quality.
        -fpsmax:v 30                                                                                                                            # Match original source FPS.
        -qmin:v 20                                                                                                                              # Limit I-frame complexity.
        -g:v 1                                                                                                                                  # Only I-frames.
        -sc_threshold:v 0                                                                                                                       # Disable scene-cut.
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

export -f convert_video_uid0004
