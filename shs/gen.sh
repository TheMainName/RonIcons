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

for s in $(ls "$src"/*.xml);
do
base=$(basename $s .xml)
echo "<item>"$base"</item>" >> icon_pack.xml
echo '<item drawable="'$base'" />' >> drawable.xml
done

echo  "</string-array>" >> icon_pack.xml
echo "</resources>" >> icon_pack.xml
echo "</resources>" >> drawable.xml


