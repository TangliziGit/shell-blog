code=0
date="$(date +%Y-%m-%d_)"
function rename(){
    for filename in `find $1 -name "*.$2" -printf '%P\n'`; do
        prefix="$(echo "$filename" | egrep "[0-9]{4}-[0-9]{2}-[0-9]{2}_")"
        if [ X$prefix = X"" ]; then
            echo "\`$filename\` is not in correct time format. (do you means $date$filename?)"
            mv "$1/$filename" "$1/$date$filename"
            code=1
        fi
    done
}

rename "post" "md"
rename "page" "html"

exit $code
