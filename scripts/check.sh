#!/usr/bin/env bash
# Static checks for the developer hub. No dependencies beyond bash + grep + python3.
#   ./scripts/check.sh            run every check
#   ./scripts/check.sh links      run one check by name
#
# These exist because each of them has caught a real defect. Diagram geometry
# cannot be checked here — it needs a browser to measure text. See README.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
say() { printf '\n\033[1m%s\033[0m\n' "$1"; }
bad() { printf '  ✗ %s\n' "$1"; fail=1; }
ok()  { printf '  ✓ %s\n' "$1"; }

pages() { ls index.html connectors/*.html api/*.html docs/*.html topics/*.html community/*.html 2>/dev/null; }

check_links() {
  say "Local links and assets resolve"
  local n=0
  while read -r f; do
    d=$(dirname "$f")
    grep -oE 'href="[^"#][^"]*"|src="[^"]*"' "$f" | sed 's/.*="//;s/"//' \
      | grep -vE '^(https?:|mailto:)' | sort -u | while read -r l; do
        t="${l%%#*}"; t="${t%%\?*}"; [ -z "$t" ] && continue
        [ -e "$d/$t" ] || echo "$f -> $l"
      done
  done < <(pages) | while read -r line; do bad "$line"; n=1; done
  [ "$fail" -eq 0 ] && ok "every local href and src resolves"
}

check_anchors() {
  say "Cross-page anchors exist"
  local found=0
  grep -ohE 'href="(\.\./)?[a-z]+/[a-z0-9.-]+\.html#[a-z-]+"' $(pages) 2>/dev/null \
    | sed 's/href="//;s/"//;s|^\.\./||' | sort -u | while read -r r; do
        f="${r%%#*}"; a="${r##*#}"
        if [ ! -e "$f" ]; then echo "missing file: $f"
        elif ! grep -q "id=\"$a\"" "$f"; then echo "missing anchor: $r"; fi
      done | while read -r line; do bad "$line"; found=1; done
  [ "$fail" -eq 0 ] && ok "every cross-page anchor target exists"
}

check_deadlinks() {
  say "No placeholder links"
  if grep -rn 'href="#"' $(pages) 2>/dev/null; then bad "href=\"#\" found"; else ok "no href=\"#\""; fi
}

check_toc() {
  say "Page contents match their sections"
  for f in build/index.html api/index.html connectors/index.html community/index.html docs/index.html topics/index.html tools/index.html; do
    [ -e "$f" ] || continue
    secs=$(grep -oE '<section id="[a-z-]+"' "$f" | sed 's/.*id="//;s/"//' | sort)
    toc=$(sed -n '/class="toc"/,/<\/div>/p' "$f" | grep -oE 'href="#[a-z-]+"' | sed 's/href="#//;s/"//' | sort)
    [ -z "$toc" ] && continue
    if [ "$secs" != "$toc" ]; then bad "$f: contents and sections differ"; else ok "$f"; fi
  done
}

check_identifiers() {
  say "No internal identifiers in published pages"
  # Member names, internal trackers and non-public hosts must not reach the hub.
  # The pattern list is itself internal, so it lives untracked in
  # scripts/identifiers.local (one extended-grep alternation on a single line).
  if [ ! -f scripts/identifiers.local ]; then
    bad "scripts/identifiers.local missing — identifier check cannot run"
    return
  fi
  local pat
  pat=$(cat scripts/identifiers.local)
  if grep -rniE "$pat" $(pages) 2>/dev/null; then bad "internal identifier found"; else ok "clean"; fi
}

check_tokens() {
  say "Colours are defined once, in hub.css"
  # A page defining its own brand hex has drifted from the shared stylesheet.
  local hits
  hits=$(grep -rnE '(color|fill|stroke) *: *#[0-9A-Fa-f]{6}' $(pages) 2>/dev/null \
         | grep -viE '#FFFFFF|#fff\b' || true)
  if [ -n "$hits" ]; then echo "$hits"; bad "literal brand hex outside hub.css"; else ok "no literal brand hex in pages"; fi
}

case "${1:-all}" in
  links) check_links ;;
  anchors) check_anchors ;;
  deadlinks) check_deadlinks ;;
  toc) check_toc ;;
  identifiers) check_identifiers ;;
  tokens) check_tokens ;;
  all) check_links; check_anchors; check_deadlinks; check_toc; check_identifiers; check_tokens ;;
  *) echo "unknown check: $1"; exit 2 ;;
esac

echo
[ "$fail" -eq 0 ] && echo "All checks passed." || echo "Some checks failed."
exit "$fail"
