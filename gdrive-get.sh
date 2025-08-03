#!/bin/bash

# Improved Google Drive file downloader script
# Supports multiple URL formats and provides better error handling

set -euo pipefail # Exit on error, undefined vars, pipe failures

# Function to extract the file ID from various Google Drive URL formats
extract_file_id() {
  local file_url="$1"
  local file_id=""

  # Handle different Google Drive URL formats
  if [[ "$file_url" =~ drive\.google\.com/file/d/([a-zA-Z0-9_-]+) ]]; then
    file_id="${BASH_REMATCH[1]}"
  elif [[ "$file_url" =~ drive\.google\.com/open\?id=([a-zA-Z0-9_-]+) ]]; then
    file_id="${BASH_REMATCH[1]}"
  elif [[ "$file_url" =~ id=([a-zA-Z0-9_-]+) ]]; then
    file_id="${BASH_REMATCH[1]}"
  else
    # Try the original sed approach as fallback
    file_id=$(echo "$file_url" | sed -n 's/.*\/file\/d\/\([a-zA-Z0-9_-]*\).*/\1/p')
  fi

  echo "$file_id"
}

# Function to get filename from Google Drive
get_filename() {
  local file_id="$1"
  local filename

  # Try to get the filename from Google Drive
  filename=$(curl -s "https://drive.google.com/file/d/$file_id/view" |
    grep -oP '(?<=<title>).*?(?= - Google Drive</title>)' |
    head -n1 || echo "")

  if [ -z "$filename" ]; then
    filename="gdrive_file_$file_id"
  fi

  # Sanitize filename (remove/replace invalid characters)
  filename=$(echo "$filename" | sed 's/[<>:"/\\|?*]/_/g')
  echo "$filename"
}

# Function to download the file with improved error handling
download_google_drive_file() {
  local file_url="$1"
  local output_file="${2:-}"

  echo "Processing Google Drive URL..."

  # Extract the file ID from the URL
  local file_id
  file_id=$(extract_file_id "$file_url")

  if [ -z "$file_id" ]; then
    echo "Error: Could not extract file ID from URL: $file_url" >&2
    echo "Supported formats:" >&2
    echo "  - https://drive.google.com/file/d/FILE_ID/view" >&2
    echo "  - https://drive.google.com/open?id=FILE_ID" >&2
    return 1
  fi

  echo "Extracted file ID: $file_id"

  # Determine output filename
  if [ -z "$output_file" ]; then
    echo "Getting filename from Google Drive..."
    output_file=$(get_filename "$file_id")
    echo "Detected filename: $output_file"
  fi

  # Create a unique temporary directory for cookies
  local temp_dir
  temp_dir=$(mktemp -d)
  local cookies_file="$temp_dir/cookies.txt"

  # Cleanup function
  cleanup() {
    rm -rf "$temp_dir"
  }
  trap cleanup EXIT

  echo "Downloading file..."

  # First, try direct download (works for small files)
  if wget --quiet --load-cookies "$cookies_file" \
    --save-cookies "$cookies_file" \
    --keep-session-cookies \
    --no-check-certificate \
    "https://drive.google.com/uc?export=download&id=$file_id" \
    -O "$output_file" 2>/dev/null; then

    # Check if we got an HTML page instead of the file (indicates large file)
    if file "$output_file" | grep -q "HTML"; then
      echo "Large file detected, using confirmation token method..."
      rm "$output_file"

      # Get confirmation token for large files
      local confirm_token
      confirm_token=$(wget --quiet --save-cookies "$cookies_file" \
        --keep-session-cookies \
        --no-check-certificate \
        "https://drive.google.com/uc?export=download&id=$file_id" \
        -O- |
        grep -oP 'confirm=\K[0-9A-Za-z_]+' | head -n1)

      if [ -n "$confirm_token" ]; then
        echo "Using confirmation token: $confirm_token"
        wget --load-cookies "$cookies_file" \
          --no-check-certificate \
          "https://drive.google.com/uc?export=download&confirm=$confirm_token&id=$file_id" \
          -O "$output_file"
      else
        echo "Error: Could not get confirmation token for large file" >&2
        return 1
      fi
    fi
  else
    echo "Error: Failed to download file" >&2
    return 1
  fi

  # Verify download
  if [ -s "$output_file" ]; then
    local file_size
    file_size=$(du -h "$output_file" | cut -f1)
    echo "Download completed successfully!"
    echo "File: $output_file"
    echo "Size: $file_size"

    # Show file type
    local file_type
    file_type=$(file -b "$output_file")
    echo "Type: $file_type"
  else
    echo "Error: Downloaded file is empty or doesn't exist" >&2
    rm -f "$output_file"
    return 1
  fi
}

# Function to show usage
show_usage() {
  echo "Usage: $0 <Google Drive URL> [output_filename]"
  echo ""
  echo "Examples:"
  echo "  $0 https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/view"
  echo "  $0 https://drive.google.com/open?id=1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
  echo "  $0 'https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/view' 'my_file.pdf'"
  echo ""
  echo "Note: The file must be publicly accessible or shared with 'Anyone with the link'"
}

# Main script execution
main() {
  # Check if required tools are available
  for tool in wget curl sed grep file; do
    if ! command -v "$tool" &>/dev/null; then
      echo "Error: Required tool '$tool' is not installed" >&2
      exit 1
    fi
  done

  # Check arguments
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    show_usage
    exit 1
  fi

  local file_url="$1"
  local output_file="${2:-}"

  # Validate URL format
  if [[ ! "$file_url" =~ drive\.google\.com ]]; then
    echo "Error: Not a valid Google Drive URL" >&2
    show_usage
    exit 1
  fi

  # Call the download function
  if download_google_drive_file "$file_url" "$output_file"; then
    echo "Script completed successfully!"
    exit 0
  else
    echo "Script failed!" >&2
    exit 1
  fi
}

# Run main function with all arguments
main "$@"
