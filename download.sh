
#!/bin/bash
set -e

DEST_DIR=./
# mkdir -p $DEST_DIR

curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq
chmod +x /usr/local/bin/yq
echo "Extracting URLs from YAML..."

# Extract the URL for the selected dataset
OSM=$(yq ".urls[] | select(.name == \"$REGION\") | .url" ./config-others.yml)

# Check if the URL is empty
if [ -z "$OSM" ]; then
    echo "Error: No URL found for the selected dataset '$REGION'."
    exit 1
else 
    # If the URL is found, proceed with the download
    echo "Downloading from: $OSM"
    curl -L -o data.pbf "$OSM"
    echo "Download completed."
fi