code=0
date="$(date +%Y-%m-%d_)"
for filename in `find post -name '*.md' -printf '%P\n'`; do
    prefix="$(echo "$filename" | egrep "[0-9]{4}-[0-9]{2}-[0-9]{2}_")"
    if [ X$prefix = X"" ]; then
        echo "\`$filename\` is not in correct time format. (do you means $date$filename?)"
        mv "post/$filename" "post/$date$filename"
        code=1
    fi
done
exit $code
