#!/bin/bash

src="${1:-.}"
dest="${2:-$src}"
TINT_COLOR="@android:color/system_accent1_700"

if [ ! -d "$src" ]; then
    echo "'$src' does not exist"
    exit 1
fi

for png_file in "$src"/*.png; do
    filename=$(basename "$png_file" .png)
    xml_file="$dest/${filename}_fg.xml"
    cat > "$xml_file" << EOF
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:src="@drawable/$filename"
    android:tint="$TINT_COLOR" />
EOF
    echo '    tools:targetApi="31" />' >> ${xml_file}
    echo ${xml_file}
done

echo "done"
