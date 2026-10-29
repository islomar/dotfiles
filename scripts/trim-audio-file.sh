#!/bin/bash

# `-c copy`` skips re-encoding, so it's instant and keeps the audio quality. 
# The cut can land a few milliseconds off because MP3 frames are about 26 ms long. 
# If you need an exact cut, drop -c copy and the audio will be re-encoded.

ffmpeg -i "your-file.mp3" -t [from-seconds] -c copy "your-file (trimmed).mp3"

# Example
# ffmpeg -i "your-file.mp3" -t 01:01:06 -c copy "your-file (trimmed).mp3"

# If you meant the opposite and want to keep the part from 01:01:06 to the end, 
# use -ss 01:01:06 instead of -t 01:01:06.