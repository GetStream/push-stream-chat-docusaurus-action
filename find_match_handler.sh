sdk_lowercase_no_space=`echo "$1" | tr '[:upper:]' '[:lower:]'`
sdk_lowercase_no_space=${sdk_lowercase_no_space/ /}

# we need to skip React matching React Native
if [ "${1/ /}" == "react" ] && [[ "$2" == *native* ]]; then
	echo "Skipping: $2"
else
	rm -rf $2
fi