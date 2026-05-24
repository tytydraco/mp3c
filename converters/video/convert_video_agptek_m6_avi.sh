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
            -show_entries stream=index \
            -of csv=p=0 \
            "$1" | grep -q .
    }

    local audio_sample_rate=22050
    local size="'if(gt(ih, iw), 240, 320)':'if(gt(ih, iw), 320, 240)'"
    local ffmpeg_args=(
        -n
        -preset:v superfast
        -profile:v baseline
        -f avi
        -x264-params "aq-mode=2"
        -vf "scale=$size:force_original_aspect_ratio=decrease,pad=$size:(ow-iw)/2:(oh-ih)/2:black,transpose=2:passthrough=portrait"
        -strict -1
        -c:v libx264
        -c:a pcm_s16le
        -pix_fmt yuv420p
        -bufsize 2M
        -maxrate 2M
        -refs 1
        -ac 1
        -ar "$audio_sample_rate"
        -r 30
    )

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0
            -map 0:a:0
        )
    else
        ffmpeg_map_args=(
            -f lavfi 
            -i "anullsrc=channel_layout=mono:sample_rate=$audio_sample_rate"
            -map 0:v:0
            -map 1:a
            -shortest
        )
    fi

    
    WINEDEBUG=-all wine converters/ffmpeg-mod.exe \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_agptek_m6_avi