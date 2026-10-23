#!/bin/bash

ffmpeg -i "your-file.mp3" -t [from-seconds] -c copy "your-file (trimmed).mp3"

# Example
# ffmpeg -i "your-file.mp3" -t 01:01:06 -c copy "your-file (trimmed).mp3"