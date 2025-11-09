#!/bin/sh
pattern=${1:-7bd3920c-c53c-40ed-8d79-4d2f601befb0}
logdir=/var/log
exitcode=1

# Search non-compressed files (exclude common compressed extensions)
grep -R --binary-files=without-match -n --color=auto --exclude='*.gz' --exclude='*.xz' --exclude='*.bz2' -- "$pattern" "$logdir" && exitcode=0

# Search compressed files (.gz, .xz, .bz2) without decompressing everything twice
find "$logdir" -type f \( -name '*.gz' -o -name '*.xz' -o -name '*.bz2' \) -print0 | xargs -0 sh -c '
pattern="$1"
shift
found=1
for f; do
  case "$f" in
    *.gz) cmd="gzip -dc -- \"$f\" 2>/dev/null | grep -n --label=\"$f\" --color=auto -- \"$pattern\"";;
    *.xz) cmd="xz -dc -- \"$f\" 2>/dev/null | grep -n --label=\"$f\" --color=auto -- \"$pattern\"";;
    *.bz2) cmd="bzip2 -dc -- \"$f\" 2>/dev/null | grep -n --label=\"$f\" --color=auto -- \"$pattern\"";;
    *) continue;;
  esac
  sh -c "$cmd" && found=0
done
[ "$found" -eq 0 ]' _ "$pattern" && exitcode=0

exit "$exitcode"