#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Please Provide url and fied name"
    exit 1
fi

URL="$1"
FIELD="$2"

# Fetch the JSON
DATA=$(curl "$URL")

# Split the nested field into parent and child
PARENT_FIELD="${FIELD%%.*}"
CHILD_FIELD="${FIELD#*.}"

# Use a while loop to read each line of the JSON
echo "$DATA" | while IFS= read -r line; do

    # Check if the line contains the parent field 
    if [[ $line == *\"$PARENT_FIELD\":* && -n "$CHILD_FIELD" ]]; then

        # Extract the child value in the next lines
        while IFS= read -r nested_line; do
            if [[ $nested_line == *\"$CHILD_FIELD\":* ]]; then
                VALUE="${nested_line##*\": \"}" # Remove everything before the last ": "
                VALUE="${VALUE%%\"*}"  # Remove everything after the first "
                echo "$VALUE"
                break
            fi
        done

    # Check if the line contains the desired field (for non-nested fields)
    elif [[ $line == *\"$FIELD\":* ]]; then
        VALUE="${line##*\": \"}"  # Remove everything before the last ": "
        VALUE="${VALUE%%\"*}"    # Remove everything after the first "
        echo "$VALUE"
    fi
done