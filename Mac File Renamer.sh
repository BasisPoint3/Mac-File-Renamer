#!/bin/bash

# Prompt the user to drag and drop a file or folder onto the terminal
echo "Please drag and drop a file or folder onto this terminal window, then press Enter:"
read -r INPUT

# Remove backslashes used by the terminal to escape spaces
INPUT="${INPUT//\\}"

# Remove any single quotes macOS might add if file path contains spaces (unlikely after above, but just in case)
INPUT="${INPUT//\'/}"

rename_file() {
    FILE="$1"
    DIR=$(dirname "${FILE}")
    BASENAME=$(basename "${FILE}")
    EXTENSION="${BASENAME##*.}"
    FILENAME="${BASENAME%.*}"

    # Convert to Proper Case
    PROPER_CASE=$(echo "${FILENAME}" | awk '{
        for(i=1;i<=NF;i++){
            $i=toupper(substr($i,1,1)) tolower(substr($i,2))
        }
    }1' RS="[._ ]" ORS=" ")

    # Trim trailing whitespace
    PROPER_CASE=$(echo "${PROPER_CASE}" | xargs)

    # Get the creation (birth) date of the file
    CREATION_DATE=$(stat -f "%SB" -t "%Y-%m-%d" "${FILE}")

    # Construct the new file name
    NEW_NAME="${DIR}/${CREATION_DATE} - ${PROPER_CASE}.${EXTENSION}"

    # Rename the file
    mv "${FILE}" "${NEW_NAME}"

    echo "File renamed to: ${NEW_NAME}"
}

if [ -d "${INPUT}" ]; then
    # Input is a directory, process each file in it
    echo "Processing directory: ${INPUT}"
    find "${INPUT}" -type f | while read -r FILE; do
        rename_file "${FILE}"
    done
elif [ -f "${INPUT}" ]; then
    # Input is a single file, process the file
    echo "Processing file: ${INPUT}"
    rename_file "${INPUT}"
else
    echo "The input is not a valid file or directory: ${INPUT}"
    exit 1
fi
