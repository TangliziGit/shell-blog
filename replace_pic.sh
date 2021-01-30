while read -r line; do
    echo "$line"
    filename=$(echo "$line" | awk -F'!' '{print $1}')
    filename=${filename: : -1}
    content=$(echo "$line" | awk -F'!' '{print $2}')
    name=$(echo "$content" | awk -F']' '{print $1}')
    name=${name: 1}
    name=$(echo "$name" | sed "s/\.[^.]*$//g")
    name="${name}_$(date +%s%N | base64)"

    url=$(echo "$content" | awk -F']' '{print $2}')
    url=${url: 1: -1}

    new=$(util/pic "$name" "$url" | tail -1)

    content=$(echo "!$content" | sed -e 's/[]\/$*.^[]/\\&/g')
    new=$(echo "$new" | sed -e 's/[]\/$*.^[]/\\&/g')

    echo "$content"
    echo "$new"
    echo ""

    if [[ $new =~ ".???" ]]; then
        echo "Error occured"
    else
        sed -i "s#$content#$new#g" "$filename"
    fi

done < <(grep -r "\!\[.*\](http.*)" .)
