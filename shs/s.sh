#!/system/bin/sh

# Set the string to remove
s1='fill="#FFFFFF"'

# Set the directory (current directory by default)
directory="/storage/emulated/0/Download/ico"

# Check if directory exists
if [[ ! -d "$directory" ]]; then
    echo "Error: Directory '$directory' does not exist."
    exit 1
fi

# Loop through all SVG files in the directory
for file in "$directory"/*.svg; do
    # Check if any SVG files exist
    if [[ ! -e "$file" ]]; then
        echo "No SVG files found in $directory"
        exit 1
    fi
    
    # Create a temporary file
    temp_file="${file}.tmp"
    
    # Remove occurrences of the string and save to temp file
    sed "s/$s1//g" "$file" > "$temp_file"
    
    # Replace the original file with the modified one
    mv "$temp_file" "$file"
    
    echo "Processed: $file"
done

echo "All SVG files processed successfully."

