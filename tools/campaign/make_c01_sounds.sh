#!/bin/sh
# The Clockwork prologue's two sounds (docs/campaign_c01_build.md), cut from the owner's clock recordings
# (art/audio_src/clockwork/, SOURCES.txt) with ffmpeg:
#   campaign/bell_toll: a strike of the old clock bell pitched down to a church bell, with a stone echo (the thirteen strokes)
#   campaign/off_beat:  the alarm clock's ticking slowed off the beat (the machine's tick: the children turning, the seeds)
cd "$(dirname "$0")/../.." || exit 1
S=art/audio_src/clockwork
mkdir -p assets/audio/campaign
ffmpeg -hide_banner -loglevel error -y -ss 1.50 -t 2.2 -i $S/old_clock_bell.mp3 \
  -af "asetrate=44100*0.62,aresample=44100,aecho=0.8:0.7:180|420:0.35|0.22,afade=t=out:st=2.4:d=1.2,volume=2.0,apad=pad_dur=0.6" \
  -ac 1 -ar 44100 assets/audio/campaign/bell_toll.wav
ffmpeg -hide_banner -loglevel error -y -ss 1.55 -t 0.9 -i $S/alarm_clock.mp3 \
  -af "atempo=0.82,volume=1.6,afade=t=out:st=0.9:d=0.2" -ac 1 -ar 44100 assets/audio/campaign/off_beat.wav
