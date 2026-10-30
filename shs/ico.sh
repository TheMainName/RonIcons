#!/data/data/com.termux/files/usr/bin/bash

set -u

LIST_FILE="${1:-list.txt}"
OUT_DIR="${2:-$HOME/extracted-icons}"
WORK_DIR="${TMPDIR:-$HOME/tmp}/icon-extract-$$"

if [[ ! -r "$LIST_FILE" ]]; then
    printf 'Cannot read list file: %s\n' "$LIST_FILE" >&2
    exit 1
fi
if ! command -v apktool >/dev/null 2>&1; then
    printf 'apktool was not found in PATH.\n' >&2
    exit 1
fi
if ! command -v su >/dev/null 2>&1; then
    printf 'su was not found; root access is required to read the APKs.\n' >&2
    exit 1
fi
if ! mkdir -p "$OUT_DIR" "$WORK_DIR"; then
    printf 'Cannot create output or temporary directory.\n' >&2
    exit 1
fi

# Quote a path for the shell used by su -c.
shell_quote() {
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

count=0
ok=0
failed=0

while IFS= read -r app_dir || [[ -n "$app_dir" ]]; do
    # Ignore empty lines and lines whose first non-space character is #.
    [[ -z "${app_dir//[[:space:]]/}" ]] && continue
    [[ "$app_dir" =~ ^[[:space:]]*# ]] && continue

    # Remove trailing whitespace, but preserve spaces within paths.
    app_dir="${app_dir%"${app_dir##*[![:space:]]}"}"
    app_dir="${app_dir#"${app_dir%%[![:space:]]*}"}"

    count=$((count + 1))
    apk_src="${app_dir%/}/base.apk"
    tag="$(basename "${app_dir%/}")"
    [[ -n "$tag" ]] || tag="app"
    tag="${tag//[^[:alnum:]_.-]/_}"
    dest="$OUT_DIR/$(printf '%03d' "$count")_$tag"
    apk_tmp="$WORK_DIR/app_$count.apk"
    decoded="$WORK_DIR/decoded_$count"

    printf '\n[%d] %s\n' "$count" "$app_dir"

    if [[ ! -d "$app_dir" ]]; then
        printf '  ERROR: source directory does not exist.\n' >&2
        failed=$((failed + 1))
        continue
    fi

    # Copy as root, then make the copied APK readable before non-root Apktool runs.
    copy_cmd="cp -- $(shell_quote "$apk_src") $(shell_quote "$apk_tmp")"
    if ! su -c "$copy_cmd"; then
        printf '  ERROR: root could not copy %s\n' "$apk_src" >&2
        failed=$((failed + 1))
        continue
    fi

    chmod_cmd="chmod 0644 -- $(shell_quote "$apk_tmp")"
    if ! su -c "$chmod_cmd"; then
        printf '  ERROR: could not change the copied APK permissions.\n' >&2
        rm -f "$apk_tmp"
        failed=$((failed + 1))
        continue
    fi

    if [[ ! -r "$apk_tmp" ]]; then
        printf '  ERROR: copied APK is not readable by Termux.\n' >&2
        rm -f "$apk_tmp"
        failed=$((failed + 1))
        continue
    fi

    if ! apktool d -f -s "$apk_tmp" -o "$decoded"; then
        printf '  ERROR: Apktool could not decode the APK.\n' >&2
        rm -f "$apk_tmp"
        failed=$((failed + 1))
        continue
    fi

    icon_xml="$decoded/res/mipmap-anydpi-v26/ic_launcher.xml"
    if [[ ! -r "$icon_xml" ]]; then
        printf '  ERROR: expected icon XML not found: %s\n' "$icon_xml" >&2
        rm -f "$apk_tmp"
        failed=$((failed + 1))
        continue
    fi

    if ! mkdir -p "$dest"; then
        printf '  ERROR: cannot create output directory: %s\n' "$dest" >&2
        rm -f "$apk_tmp"
        failed=$((failed + 1))
        continue
    fi

    if ! cp -- "$icon_xml" "$dest/ic_launcher.xml"; then
        printf '  ERROR: failed to copy the launcher XML.\n' >&2
        rm -f "$apk_tmp"
        failed=$((failed + 1))
        continue
    fi

    # Copy directly referenced mipmap/drawable resources (for example,
    # the adaptive icon's foreground layer). A @color reference is not an image.
    while IFS= read -r ref; do
        [[ -n "$ref" ]] || continue
        name="${ref#*/}"

        found=0
        while IFS= read -r resource; do
            [[ -n "$resource" ]] || continue
            rel="${resource#"$decoded"/}"
            target="$dest/$rel"

            if ! mkdir -p "$(dirname "$target")" ||
               ! cp -- "$resource" "$target"; then
                printf '  ERROR: failed to copy referenced resource: %s\n' "$resource" >&2
                found=2
                break
            fi
            found=1
        done < <(
            find "$decoded/res" -type f -name "$name.*" \
                \( -path '*/mipmap-*/*' -o -path '*/drawable-*/*' \) \
                2>/dev/null
        )

        if [[ "$found" -eq 0 ]]; then
            printf '  Note: no mipmap/drawable file found for %s (it may be a color reference).\n' "$ref"
        elif [[ "$found" -eq 2 ]]; then
            break
        fi
    done < <(grep -oE '@(mipmap|drawable)/[A-Za-z0-9_.]+' "$icon_xml" | sort -u)

    if [[ "${found:-0}" -eq 2 ]]; then
        rm -f "$apk_tmp"
        failed=$((failed + 1))
        continue
    fi

    printf '  Extracted resources to: %s\n' "$dest"
    rm -f "$apk_tmp"
    rm -rf "$decoded"
    ok=$((ok + 1))
done < "$LIST_FILE"

rm -rf "$WORK_DIR"

printf '\nDone: %d succeeded, %d failed.\n' "$ok" "$failed"
[[ "$failed" -eq 0 ]]
