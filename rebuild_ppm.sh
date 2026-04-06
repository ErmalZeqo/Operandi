#!/bin/sh
# Usage: ./rebuild_ppm.sh header.ppm data.bin.ecb image_ecb.ppm

set -eu

if [ $# -ne 3 ]; then
  echo "Usage: $0 <header.ppm> <data.bin.xxx> <output.ppm>" >&2
  exit 1
fi

header="$1"
data="$2"
outfile="$3"

cat "$header" "$data" > "$outfile"
echo "Image reconstruite : $outfile"
