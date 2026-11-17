#!/bin/sh
# The Brood prologue's three sounds (docs/campaign_b01_build.md), made from the Brood's own creature voices with ffmpeg:
#   campaign/linnea_call:   the Brood Mother's call raised to a young one's rising trill (Linnea calls; the Sire calls with her)
#   campaign/forest_answer: a Raptor's cry far off in the trees, slowed and echoed (her kin answer from the forest)
#   campaign/sire_roar:     the Tyrant Sire's roar pitched down, long and heavy (the ground shakes)
# Stand-ins: the owner may replace any of them (same names).
cd "$(dirname "$0")/../.." || exit 1
V=assets/voice
mkdir -p assets/audio/campaign
ffmpeg -hide_banner -loglevel error -y -i $V/brood_mother/select_1.wav \
  -af "asetrate=44100*1.55,aresample=44100,vibrato=f=9:d=0.35,aecho=0.8:0.6:90:0.25,volume=1.6,afade=t=out:st=1.2:d=0.5" \
  -ac 1 -ar 44100 assets/audio/campaign/linnea_call.wav
ffmpeg -hide_banner -loglevel error -y -i $V/raptor/select_1.wav \
  -af "asetrate=44100*0.85,aresample=44100,aecho=0.8:0.7:260|520:0.4|0.25,highpass=f=180,lowpass=f=3200,volume=1.3,apad=pad_dur=0.6" \
  -ac 1 -ar 44100 assets/audio/campaign/forest_answer.wav
ffmpeg -hide_banner -loglevel error -y -i $V/tyrannosaur/select_1.wav \
  -af "asetrate=44100*0.7,aresample=44100,aecho=0.8:0.6:200:0.3,volume=2.0,apad=pad_dur=0.5" \
  -ac 1 -ar 44100 assets/audio/campaign/sire_roar.wav
