#!/bin/sh
# Usage: ./encrypt_data.sh data.bin
# Produit :
#   data.bin.ecb
#   data.bin.cbc

set -eu

if [ $# -ne 1 ]; then
  echo "Usage: $0 <data.bin>" >&2
  exit 1
fi

infile="$1"

# Clé AES-128 fixe (16 octets = 32 hex digits)
KEY="00112233445566778899aabbccddeeff"

# IV fixe pour CBC (16 octets = 32 hex digits)
IV="0102030405060708090a0b0c0d0e0f10"

size=$(wc -c < "$infile" | tr -d ' ')
pad=$(( (16 - (size % 16)) % 16 ))
padded_size=$(( size + pad ))

tmp_padded=$(mktemp)
trap 'rm -f "$tmp_padded"' EXIT

cp "$infile" "$tmp_padded"
if [ "$pad" -ne 0 ]; then
  dd if=/dev/zero bs=1 count="$pad" status=none >> "$tmp_padded"
fi

# ECB
openssl enc -aes-128-ecb -K "$KEY" -nosalt -nopad \
  -in "$tmp_padded" -out "${infile}.ecb.full"

head -c "$size" "${infile}.ecb.full" > "${infile}.ecb"
rm -f "${infile}.ecb.full"

# CBC
openssl enc -aes-128-cbc -K "$KEY" -iv "$IV" -nosalt -nopad \
  -in "$tmp_padded" -out "${infile}.cbc.full"

head -c "$size" "${infile}.cbc.full" > "${infile}.cbc"
rm -f "${infile}.cbc.full"

echo "Fichiers produits :"
echo "  ${infile}.ecb"
echo "  ${infile}.cbc"
