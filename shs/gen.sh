#!/bin/bash

src="${1:-.}"

cat << EOF > icon_pack.xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools" tools:ignore="ExtraTranslation">
    <string-array name="all">
EOF

cat << EOF > drawable.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
<version>1</version>
<category title="All" />
EOF

while IFS= read -r line || [[ -n "$line" ]]; do
base=$(basename $line .xml)
echo "<item>"$base"</item>" >> icon_pack.xml
echo '<item drawable="'$base'" />' >> drawable.xml
done < names.txt

echo  "</string-array>" >> icon_pack.xml
echo "</resources>" >> icon_pack.xml
echo "</resources>" >> drawable.xml



