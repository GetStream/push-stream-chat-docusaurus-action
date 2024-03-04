sdk_lowercase_no_space=`echo "$1" | tr '[:upper:]' '[:lower:]'`
sdk_lowercase_no_space=${sdk_lowercase_no_space/ /}

path_lowercase=`echo "$2" | tr '[:upper:]' '[:lower:]'`

# we need to skip React matching React Native
if [ "$sdk_lowercase_no_space" == "react" ] && { [[ "$path_lowercase" == *reactnative* ]] || [[ "$path_lowercase" == *react-native* ]]; } ; then
    echo "Skipping: $2"
else
    echo "Deleting: $2"
    rm -rf $2
fi