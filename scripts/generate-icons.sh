#!/bin/bash

set -eou pipefail

SRC=assets/launcher.svg
RES_DIR=android/app/src/main/res
FILENAME=ic_launcher.png

inkscape -z "$SRC" -w 48 -h 48 -e "$RES_DIR/mipmap-mdpi/$FILENAME"
inkscape -z "$SRC" -w 72 -h 72 -e "$RES_DIR/mipmap-hdpi/$FILENAME"
inkscape -z "$SRC" -w 96 -h 96 -e "$RES_DIR/mipmap-xhdpi/$FILENAME"
inkscape -z "$SRC" -w 144 -h 144 -e "$RES_DIR/mipmap-xxhdpi/$FILENAME"
inkscape -z "$SRC" -w 192 -h 192 -e "$RES_DIR/mipmap-xxxhdpi/$FILENAME"
inkscape -z "$SRC" -w 512 -h 512 -e "$RES_DIR/mipmap-web/$FILENAME"

inkscape -z assets/feature.svg -w 1024 -h 500 -e assets/feature.png
