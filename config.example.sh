#!/usr/bin/env bash

PRESERVE_ORIGINAL="true"
CONVERTERS_AUDIO=(
    "convert_audio_adts_aac"
    "convert_audio_mp3"
)
CONVERTERS_IMAGE=(
    "convert_image_generic_jpg"
    "convert_image_generic_bmp"
)
CONVERTERS_TEXT=(
    "convert_text_txt"
)
CONVERTERS_VIDEO=(
    "convert_video_generic_mp4"
    "convert_video_240x320_h264_pcms16le_avi"
    "convert_video_240x296_h264_pcms16le_avi"
    "convert_video_128x160_mjpeg_pcms16le_avi"
    "convert_video_generic_amv"
)

export PRESERVE_ORIGINAL
export CONVERTERS_AUDIO
export CONVERTERS_IMAGE
export CONVERTERS_TEXT
export CONVERTERS_VIDEO