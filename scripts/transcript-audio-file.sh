#!/bin/bash

source ~/venvs/whisper/bin/activate

whisper "your-audio.mp3" \
  --language en \
  --task transcribe \
  --model small \
  --output_format txt

# You can also generate subtitles/timestamps instead of plain text, for example:
# whisper "your-audio.mp3" --language en --model small --output_format srt
# whisper "your-audio.mp3" --language en --model small --output_format all