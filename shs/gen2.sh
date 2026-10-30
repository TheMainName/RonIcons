#!/bin/bash

src="${1:-.}"

cat << EOF > appfilter.xml
<?xml version="1.0" encoding="UTF-8"?>
<resources>
EOF

cat << EOF > appmap.xml
<?xml version="1.0" encoding="UTF-8"?>
<appmap>
EOF

while IFS= read -r line || [[ -n "$line" ]]; do

echo '<item'>> appfilter.xml
echo 'component="'$line'"' >> appfilter.xml
echo 'drawable="TODO"/>' >> appfilter.xml

echo  '<item class="'$line ' name="fillin"/>' >> appmap.xml

done < info.txt

echo "</resources>" >> appfilter.xml
echo "</appmap>" >> appmap.xml
