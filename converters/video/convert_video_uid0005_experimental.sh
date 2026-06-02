#!/usr/bin/env bash

# Experimental reverse-engineered ATJ MJPEG AVI.
function convert_video_uid0005_experimental() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0005.avi"

    local tmpdir="$(mktemp -d)"

    function has_audio() {
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries "stream=index" \
            -of "csv=p=0" \
            "$1" | grep -q .
    }

    function duration_original() {
        ffprobe \
            -v error \
            -show_entries "format=duration" \
            -of "default=noprint_wrappers=1:nokey=1" \
            "$input_file"
    }

    local duration
    local n_frames

    duration="$(duration_original)"
    duration="${duration%.*}"
    n_frames="$((duration * 542 / 25))"

    local ffmpeg_map_args=()
    if has_audio "$input_file"; then
        ffmpeg_map_args=(
            -map 0:v:0                                              # Choose first video stream.
            -map 0:a:0                                              # Choose first audio stream.
            -ar:a 22050                                             # 22.05 kHz audio rate.
        )
    else
        ffmpeg_map_args=(
            -f lavfi                                                # Virtual audio device.
            -i "anullsrc=channel_layout=mono:sample_rate=22050"     # 22.05 kHz silent audio.
            -map 0:v:0                                              # Choose first video stream.
            -map 1:a                                                # Include silent audio.
            -ar:a 22050                                             # 22.05 kHz audio rate.
            -shortest                                               # Stop encoding when video stream ends.
        )
    fi

    local vf="scale=128:128:force_original_aspect_ratio=decrease,pad=128:128:(ow-iw)/2:(oh-ih)/2:black,fps=542/25"
    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
        -filter:v "$vf" \
        -pix_fmt yuvj420p \
        -c:v mjpeg \
        -ac:a 1 \
        -c:a adpcm_ima_wav \
        -ar:a 22050 \
        -block_size:a 512 \
        "$tmpdir/element.avi"
    ffmpeg \
        -i "$input_file"  \
        -filter:v "$vf" \
        -an \
        -c:v rawvideo \
        -pix_fmt yuv420p \
        -f rawvideo \
        "$tmpdir/element.yuv"

    python3 "$SCRIPT_DIR/tools/ffmpeg/atj-avi-encoder/build_scan_mjpeg.py" \
        turbo \
        "$tmpdir/element.avi" \
        "$tmpdir/element.yuv" \
        "$output_file" \
        -n "$n_frames" \
        -q "14" \
        --fit tier

    rm -rf "$tmpdir"
}

export -f convert_video_uid0005_experimental