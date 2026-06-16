#!/usr/bin/env bash

# Experimental reverse-engineered ATJ MJPEG AVI.
function convert_video_uid0005_mjpeg_avi() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0005.avi"

    local tmpdir
    tmpdir="$(mktemp -d)"

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
            -map 0:v:0
            -map 0:a:0
            -ar:a 22050
        )
    else
        ffmpeg_map_args=(
            -f lavfi
            -i "anullsrc=channel_layout=mono:sample_rate=22050"
            -map 0:v:0
            -map 1:a
            -ar:a 22050
            -shortest
        )
    fi

    local vf="scale=128:128:force_original_aspect_ratio=decrease,pad=128:128:(ow-iw)/2:(oh-ih)/2:black,fps=542/25"
    local ffmpeg_p1_args=(
        -y
        -c:v mjpeg
        -filter:v "$vf"
        -pix_fmt:v yuvj420p
        -c:a adpcm_ima_wav
        -ac:a 1
        -ar:a 22050
        -block_size:a 512
    )
    local ffmpeg_p2_args=(
        -y
        -f rawvideo
        -c:v rawvideo
        -filter:v "$vf"
        -pix_fmt:v yuv420p
        -an
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_map_args[@]}" \
         "${ffmpeg_p1_args[@]}" \
        "$tmpdir/element.avi"
    ffmpeg \
        -i "$input_file"  \
        "${ffmpeg_p2_args[@]}" \
        "$tmpdir/element.yuv"

    python3 "$SCRIPT_DIR/tools/ffmpeg/atj-avi-encoder/build_scan_mjpeg.py" \
        turbo \
        "$tmpdir/element.avi" \
        "$tmpdir/element.yuv" \
        "$output_file" \
        -n "$n_frames" \
        -q "0" \
        --fit tier

    rm -rf "$tmpdir"
}

export -f convert_video_uid0005_mjpeg_avi
