#!/usr/bin/env bash

FFMPEG_MOD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/ffmpeg-mod.exe"

function convert_video_uid0002() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0002.avi"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    function fps_original() {
        local fps_original

        fps_original="$(ffprobe \
            -v error \
            -select_streams v:0 \
            -show_entries "stream=avg_frame_rate" \
            -of csv=p=0 \
            "$1" | awk -F '/' '{ if ($2) print $1 / $2; else print $1 }')"
        
        echo "${fps_original:-30}"
    }

    # Scale bitrate using the frame rate, using 2 Mbps @ 30fps as a reference point.
    function scaled_bitrate() {
        local fps="$1"
        
        # reference_bitrate kbps @ reference_fps fps. Device can handle up to 10 Mbps.
        local max_bitrate=10000
        local reference_bitrate=1500
        local reference_fps=30 
        awk \
            -v fps="$fps" \
            -v m_bitrate="$max_bitrate" \
            -v r_bitrate="$reference_bitrate" \
            -v r_fps="$reference_fps" \
            'BEGIN { v = r_bitrate * fps / r_fps; if (v > m_bitrate) v = m_bitrate; if (v < 1) v = 1; printf "%d", v }'
    }

    local fps
    local bitrate
    fps="$(fps_original "$input_file")"
    bitrate="$(scaled_bitrate "$fps")"

    local size="'if(gt(ih, iw), 240, 288)':'if(gt(ih, iw), 288, 240)'"
    local ffmpeg_args=(
        -n                                                                                                                                      # Do not replace existing files.
        -f avi                                                                                                                                  # AVI container.
        -c:v libx264                                                                                                                            # H.264 codec.
        -x264-params "aq-mode=3:aq-strength=0.8"                                                                                                # Auto-variance AQ for dark scenes.
        -profile:v baseline                                                                                                                     # H.264 baseline profile.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease,pad=$size:(ow-iw)/2:(oh-ih)/2:black,transpose=cclock:passthrough=portrait"  # Contain within size, preserve aspect ratio, pad, pre-rotate counter-clockwise (portrait bypass).
        -pix_fmt:v yuvj420p                                                                                                                     # Full range pixel format.
        -b:v "${bitrate}K"                                                                                                                      # Target average bitrate.
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

    WINEDEBUG=-all wine "$FFMPEG_MOD" \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export FFMPEG_MOD
export -f convert_video_uid0002