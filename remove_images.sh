#!/bin/bash

# based on: https://gist.github.com/jaytaylor/86d5efaddda926a25fa68c263830dac1
# changes:
# - Check for images older than a year

registry=$1
image=$2
user=$3
password=$4
if [ -z "$5" ]; then
    levels=5
else
    levels=$5
fi

# Function to check tags older than a year
check_tags_older_than_a_year() {
    local registry=$1
    local image=$2
    local user=$3
    local password=$4
    local levels=$5

    # TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${user}'", "password": "'${password}'"}' https://${registry}/v2/users/login/ | jq -r .token)

    # local tags=$(curl -s -u "$user:$password" "https://${registry}/v2/${image}/tags/list" | jq -r '.tags // [] | .[]')
    local tags=$(curl -s -u "$user:$password" "https://${registry}/v2/${image}/tags/list" | jq -r '.tags // [] | map(select(. != "dev" and . != "latest" and . != "prod" and . != "stage")) | .[]')
    declare -A tags_and_date

    if [[ -n $tags ]]; then
        for tag in $tags; do

            local created_time=$(curl -s -u $user:$password -H 'Accept: application/vnd.docker.distribution.manifest.v1+json' -X GET https://$registry/v2/$image/manifests/$tag | jq -r '[.history[]]|map(.v1Compatibility|fromjson|.created)|sort|reverse|.[0]')
            local created_timestamp=$(date --date="$created_time" +%s)
            tags_and_date["$tag"]=$created_timestamp

        done
    else
        echo "No tags found for image $image."
    fi

    tags_and_date_sorted=($(for tag in "${!tags_and_date[@]}"; do echo "$tag ${tags_and_date[$tag]}"; done | sort -k2 -nr))
    tags_to_delete=("${tags_and_date_sorted[@]:$((levels * 2))}")

    if [[ -n $tags_to_delete ]]; then
        for ((i = 0; i < ${#tags_to_delete[@]}; i += 2)); do
            tag=${tags_to_delete[i]}
            timestamp=${tags_to_delete[i + 1]}
            echo "Tag $tag of image $image. Time $timestamp. Deleting..."
            # Uncomment the following line to actually delete the tag
            curl -s -u "$user:$password" -X DELETE "https://${registry}/v2/${image}/manifests/$(curl -s -I -u "$user:$password" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "https://${registry}/v2/${image}/manifests/${tag}" | grep -i 'docker-content-digest' | awk -F': ' '{print $2}' | sed 's/[\r\n]//g')"
        done
    else
        echo "No tags found for image $image."
    fi
}

check_tags_older_than_a_year "$registry" "$image" "$user" "$password" "$levels"

# Main function
main() {
    echo "Specify private image registry url without https://"
    read -r registry

    echo "List images, separated by space"
    read -r images

    echo "Registry User:"
    read -r user

    echo "Registry Password:"
    read -s password

    IFS=' ' read -r -a images_array <<<"$images"
    for image in "${images_array[@]}"; do
        echo "Checking tags for image $image..."
        check_tags_older_than_a_year "$registry" "$image" "$user" "$password"
    done
}

# Run the main function
# main
