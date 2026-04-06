#!/bin/sh
# Usage: ./measure_time.sh ls -l

if [ $# -lt 1 ]; then
  echo "Usage: $0 command [args...]"
  exit 1
fi

start=$(date +%s%N)

"$@"

end=$(date +%s%N)

elapsed_ns=$((end - start))
elapsed_ms=$((elapsed_ns / 1000000))

echo "Temps écoulé : ${elapsed_ms} ms"
