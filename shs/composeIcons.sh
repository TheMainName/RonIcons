#!/bin/bash

for fg in *_fg.xml; do
  filename=$(basename "$fg" .xml)
  nm=$(basename "$filename" _fg)~
  cat > "${nm}.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/bg" />
EOF
  echo '    <foreground android:drawable="@drawable/'${filename}'_fg" />' >> ${res}
  echo '    <monochrome android:drawable="@drawable/'${filename}'_fg" />'  >> ${res}
echo '</adaptive-icon>' >> ${fg}
done