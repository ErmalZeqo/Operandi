#!/bin/sh

set -eu

INPUT="bigfile.bin"
TMP_OUT="out.bin"

if [ ! -f "$INPUT" ]; then
  echo "Fichier $INPUT introuvable"
  exit 1
fi

KEY128="00112233445566778899aabbccddeeff"
KEY192="00112233445566778899aabbccddeeff0011223344556677"
KEY256="00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff"
IV="0102030405060708090a0b0c0d0e0f10"

echo "Algorithme ; Temps (ms)"

run_test() {
  name="$1"
  shift

  start=$(date +%s%N)
  "$@" >/dev/null 2>/dev/null
  end=$(date +%s%N)

  elapsed_ms=$(( (end - start) / 1000000 ))
  echo "$name ; $elapsed_ms"
}

run_test "AES-128-ECB" openssl enc -aes-128-ecb -K "$KEY128" -nosalt -in "$INPUT" -out "$TMP_OUT"
run_test "AES-128-CBC" openssl enc -aes-128-cbc -K "$KEY128" -iv "$IV" -nosalt -in "$INPUT" -out "$TMP_OUT"
run_test "AES-192-ECB" openssl enc -aes-192-ecb -K "$KEY192" -nosalt -in "$INPUT" -out "$TMP_OUT"
run_test "AES-256-ECB" openssl enc -aes-256-ecb -K "$KEY256" -nosalt -in "$INPUT" -out "$TMP_OUT"
run_test "DES-CBC"     openssl enc -des-cbc     -k secret -nosalt -in "$INPUT" -out "$TMP_OUT"
run_test "DES-EDE3-CBC" openssl enc -des-ede3-cbc -k secret -nosalt -in "$INPUT" -out "$TMP_OUT"

rm -f "$TMP_OUT"
