code=0
for filename in `ls post/`; do
    extension="$(echo $filename | egrep ".md$")"
    if [[ $extension == "" ]]; then
        echo "\`$filename\` is not a markdown file."
        code=1
    fi
done
exit $code
