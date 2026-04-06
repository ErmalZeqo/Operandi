#!/bin/sh
# Usage: ./split_ppm.sh image.ppm header.ppm data.bin

set -eu

if [ $# -ne 3 ]; then
  echo "Usage: $0 <input.ppm> <header.out> <data.out>" >&2
  exit 1
fi

infile="$1"
headerfile="$2"
datafile="$3"

header_len=$(
perl -e '
  use strict;
  use warnings;
  my $f = shift;
  open my $fh, "<:raw", $f or die "Cannot open $f\n";
  local $/;
  my $buf = <$fh>;

  pos($buf) = 0;

  sub skip_ws_and_comments {
    while (1) {
      if ($buf =~ /\G(?:\s+)/gc) {
        next;
      }
      if ($buf =~ /\G\#.*?\n/gc) {
        next;
      }
      last;
    }
  }

  skip_ws_and_comments();
  $buf =~ /\GP6/gc or die "Not a P6 PPM file\n";

  skip_ws_and_comments();
  $buf =~ /\G(\d+)/gc or die "Missing width\n";

  skip_ws_and_comments();
  $buf =~ /\G(\d+)/gc or die "Missing height\n";

  skip_ws_and_comments();
  $buf =~ /\G(\d+)/gc or die "Missing maxval\n";

  $buf =~ /\G(\s)/gc or die "Missing whitespace after maxval\n";

  print pos($buf);
' "$infile"
)

dd if="$infile" of="$headerfile" bs=1 count="$header_len" status=none
dd if="$infile" of="$datafile" bs=1 skip="$header_len" status=none

echo "Entête extrait dans: $headerfile"
echo "Données extraites dans: $datafile"
echo "Taille entête: $header_len octets"
