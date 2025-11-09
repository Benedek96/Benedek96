#!/bin/sh
# Simple POSIX tests for the log-search script logic.
# Creates a temporary script copy, sample logs (plain + gz) and asserts exit codes and output.

set -u

fail() { echo "FAIL: $1"; exit 1; }

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

SCRIPT="$TMPDIR/log-search.sh"
cat > "$SCRIPT" <<'SH'
#!/bin/sh
pattern=${1:-7bd3920c-c53c-40ed-8d79-4d2f601befb0}
logdir=${LOGDIR:-/var/log}
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
SH

chmod +x "$SCRIPT"

LOGDIR="$TMPDIR/logs"
mkdir -p "$LOGDIR"

# plain file with match
printf "no match here\n" > "$LOGDIR/a.log"
printf "prefix 7bd3920c-c53c-40ed-8d79-4d2f601befb0 suffix\n" > "$LOGDIR/match.log"

# gzipped file with match
printf "gz match 7bd3920c-c53c-40ed-8d79-4d2f601befb0\n" > "$LOGDIR/c.log"
gzip -c "$LOGDIR/c.log" > "$LOGDIR/c.log.gz"
rm "$LOGDIR/c.log"

# Helper to run and capture
run_and_capture() {
  LOGDIR="$LOGDIR" "$SCRIPT" "$1" 2>/dev/null | sed -r 's/\x1b\[[0-9;]*m//g'
  return $?
}

# Test 1: plain file match
out=$(run_and_capture "" ) || rc=$?; rc=${rc:-0}
if [ "$rc" -ne 0 ]; then fail "expected exit 0 when plain match present"; fi
printf "%s" "$out" | grep -q "match.log" || fail "expected output to contain match.log"

# Test 2: remove plain match, keep only gz
rm -f "$LOGDIR/match.log"
out=$(run_and_capture "" ) || rc=$?; rc=${rc:-0}
if [ "$rc" -ne 0 ]; then fail "expected exit 0 when gz match present"; fi
printf "%s" "$out" | grep -q "c.log.gz" || printf "%s" "$out" | grep -q "c.log" || fail "expected output to contain c.log.gz or c.log"

# Test 3: absent pattern
out=$(run_and_capture "no-such-pattern-xyz" ) || rc=$?; rc=${rc:-0}
if [ "$rc" -eq 0 ]; then fail "expected non-zero exit when pattern absent"; fi

# Test 4: custom pattern argument
printf "custom-pattern-123\n" > "$LOGDIR/custom.log"
out=$(LOGDIR="$LOGDIR" "$SCRIPT" "custom-pattern-123" 2>/dev/null | sed -r 's/\x1b\[[0-9;]*m//g') || rc=$?; rc=${rc:-0}
if [ "$rc" -ne 0 ]; then fail "expected exit 0 when custom pattern passed"; fi
printf "%s" "$out" | grep -q "custom.log" || fail "expected output to contain custom.log"

echo "All tests passed"
exit 0
