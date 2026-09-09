#!/usr/bin/env bash

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

_temporal_gop() {
	local -r fps="$1"
	local -r seconds="$2"
	awk -v fps="$fps" -v seconds="$seconds" \
		'BEGIN { r = int( ( seconds * fps + 0.5 )); print ( r < 1 ? 1 : r ) }'
}

convert_video_uid0018() {
	[[ -n "${1:-}" ]] || return 1

	local -r input_file="$1"
	local -r output_file="${2:-${input_file%.*}.uid0018.mp4}"

	local fps
	fps="$(_choose_fps "$input_file")" || return 1

	local gop
	gop="$(_temporal_gop "$fps" 4)" || return 1

	local -r size='320:240'
	local -r ffmpeg_args=(
		-f mp4
		-map 0:v:0
		-map '0:a:0?'
		-c:v mpeg4
		-filter:v
		"
			transpose=cclock:passthrough=landscape,
			scale=$size:force_original_aspect_ratio=increase:flags=area:out_range=tv,
			crop=$size
		"
		-sws_flags 'accurate_rnd+full_chroma_int+full_chroma_inp'
		-pix_fmt:v yuv420p
		-b:v 250k
		-g:v "$gop"
		-r:v "$fps"
		-c:a aac
		-ac:a 1
		-ar:a 16000
	)

	local passlog_dir
	passlog_dir="$(mktemp -d)" || return 1
	local -r passlog="$passlog_dir/log"
	ffmpeg \
		-nostdin \
		-n \
		-i "$input_file" \
		"${ffmpeg_args[@]}" \
		-pass 1 \
		-passlogfile "$passlog" \
		-an \
		-f null \
		/dev/null
	ffmpeg \
		-nostdin \
		-n \
		-i "$input_file" \
		"${ffmpeg_args[@]}" \
		-pass 2 \
		-passlogfile "$passlog" \
		"$output_file"
	rm -rf "$passlog_dir"
	MP4Box \
		-inter 1 \
		-tmp "$(dirname -- "$output_file")" \
		"$output_file"
}

export -f _choose_fps
export -f _temporal_gop
export -f convert_video_uid0018

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	convert_video_uid0018 "$@"
fi
