#!/usr/bin/env bash

_has_audio() {
	local output

	output="$(ffprobe \
		-v error \
		-select_streams a:0 \
		-show_entries stream=index \
		-of csv=p=0 \
		"$1")" || return 1

	[[ -n "$output" ]]
}

_choose_fps() {
	local -r fps_max=25
    local fps_raw
	local fps_original

    fps_raw="$(ffprobe \
		-v error \
		-select_streams v:0 \
		-show_entries stream=avg_frame_rate \
		-of csv=p=0 \
		"$1")" || return 1
	fps_original="$(awk -F '/' \
		'{ if ($2) print $1 / $2; else print $1 }' <<< "$fps_raw")"
	fps_original="${fps_original:-$fps_max}"

	awk -v fps="$fps_original" -v max="$fps_max" \
		'BEGIN { if (fps > max) print max; else print fps }'
}

convert_video_uid0013() {
	[[ -n "${1:-}" ]] || return 1

	local -r input_file="$1"
	local -r output_file="${2:-${input_file%.*}.uid0013.avi}"

	local fps
	fps="$(_choose_fps "$input_file")" || return 1

	local -r size='160:128'
	local -r ffmpeg_args=(
		-f avi
		-c:v mjpeg
		-filter:v
		"
            transpose=cclock:passthrough=landscape,
            scale=$size:force_original_aspect_ratio=increase:flags=area,
            crop=$size,
            hflip
        "
		-sws_flags 'accurate_rnd+full_chroma_int+full_chroma_inp'
		-pix_fmt:v yuvj420p
		-r:v "$fps"
		-b:v 600k
		-c:a pcm_s16le
		-ac:a 2
	)

	local ffmpeg_map_args=()
	if _has_audio "$input_file"; then
		ffmpeg_map_args=(
			-map 0:v:0
			-map 0:a:0
			-ar:a 22050
		)
	else
		ffmpeg_map_args=(
			-f lavfi
			-i 'anullsrc=channel_layout=stereo:sample_rate=16000'
			-map 0:v:0
			-map 1:a
			-ar:a 16000
			-shortest
		)
	fi

	local passlog_dir
	passlog_dir="$(mktemp -d)" || return 1
	local -r passlog="$passlog_dir/log"
	ffmpeg \
		-nostdin \
		-n \
		-i "$input_file" \
		"${ffmpeg_map_args[@]}" \
		"${ffmpeg_args[@]}" \
		-pass 1 \
		-passlogfile "$passlog" \
		-an \
		-f null \
		/dev/null || return 1
	ffmpeg \
		-nostdin \
		-n \
		-i "$input_file" \
		"${ffmpeg_map_args[@]}" \
		"${ffmpeg_args[@]}" \
		-pass 2 \
		-passlogfile "$passlog" \
		"$output_file" || return 1
	rm -rf "$passlog_dir"
}

export -f _has_audio
export -f _choose_fps
export -f convert_video_uid0013

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_video_uid0013 "$@"
