#/system/bin/sh
cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER | grep '/' >> info.txt

