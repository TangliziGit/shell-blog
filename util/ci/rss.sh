# render <template name>

item_template="$(cat template/item.rss)"
items=""
for filename in `ls -1r post/*.md | head -5`; do
    name="$(echo $filename | sed "s/post\///g")"
    date="$(echo $name | grep -oP "^.+?(?=_)")"
    content="$(pandoc $filename -t html)"

    name="$(printf "$name" | sed -e 'H;${x;s/\n/\\n/g;s/^\\n//;p;};d')"
    date="$(printf "$date" | sed -e 'H;${x;s/\n/\\n/g;s/^\\n//;p;};d')"
    content="$(printf "%s" "$content" | sed -e 'H;${x;s/\n/\\n/g;s/^\\n//;p;};d')"
    
    item=$item_template
    item="$(printf "$item" | a='\$\$name\$\$' b="$name" perl -pe 's/$ENV{a}/$ENV{b}/g')"
    item="$(printf "$item" | a='\$\$date\$\$' b="$date" perl -pe 's/$ENV{a}/$ENV{b}/g')"
    item="$(printf "$item" | a='\$\$content\$\$' b="$content" perl -pe 's/$ENV{a}/$ENV{b}/g')"
    items="$items $item"
done

rss="$(cat template/post.rss)"
export IFS=$'\n'
for key in `grep -oP "(?<={{)[^}]*(?=}})" template/post.rss`; do
    value="$(eval "${key}" | tr '\n' '\a' | sed "s/\a/|||/g" |  sed "s/|||$//g")"

    value="$(printf "$value" | sed "s/\//\\\\\//g")"
    value="$(printf "$value" | sed -e 'H;${x;s/\n/\\n/g;s/^\\n//;p;};d')"
    key="$(printf "$key" | sed "s/\//\\\\\//g")"
    key="$(printf "$key" | sed "s/\*/\\\\*/g")"
    key="$(printf "$key" | sed -e 'H;${x;s/\n/\\n/g;s/^\\n//;p;};d')"

    rss="$(printf "$rss" | sed "s/{{$key}}/$value/g")"
done
unset IFS

# printf "$items"
rss="$(printf "%s" "$rss" | a='\$\$items\$\$' b="$items" perl -pe 's/$ENV{a}/$ENV{b}/g')"
printf "%s" "$rss" > post.rss
