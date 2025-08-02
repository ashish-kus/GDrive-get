# Google Drive File Downloader

A robust bash script to download files from Google Drive using sharing links. This script handles various Google Drive URL formats, automatically detects filenames, and properly manages large file downloads that require confirmation tokens.

## Features

- ✅ **Multiple URL Format Support** - Works with different Google Drive sharing link formats
- ✅ **Automatic Filename Detection** - Extracts the actual filename from Google Drive
- ✅ **Large File Handling** - Properly manages files that require confirmation tokens
- ✅ **Smart Error Handling** - Comprehensive error checking and user-friendly messages
- ✅ **Download Verification** - Confirms successful downloads and displays file information
- ✅ **Safe Temporary Files** - Secure handling of temporary cookies and cleanup
- ✅ **Dependency Checking** - Verifies required tools are installed before running

## Requirements

The script requires the following tools to be installed on your system:

- `wget` - For downloading files
- `curl` - For making HTTP requests
- `sed` - For text processing
- `grep` - For pattern matching
- `file` - For file type detection

Most Linux distributions and macOS include these tools by default.

### Installing Requirements

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install wget curl sed grep file
```

**CentOS/RHEL/Fedora:**

```bash
sudo yum install wget curl sed grep file
# or for newer versions:
sudo dnf install wget curl sed grep file
```

**macOS:**

```bash
# Using Homebrew
brew install wget
# Other tools are pre-installed
```

## Installation

1. Download the script:

```bash
curl -O https://raw.githubusercontent.com/yourusername/gdrive-downloader/main/gdrive-download.sh
```

2. Make it executable:

```bash
chmod +x gdrive-download.sh
```

3. Optionally, move it to your PATH:

```bash
sudo mv gdrive-download.sh /usr/local/bin/gdrive-download
```

## Usage

### Basic Syntax

```bash
./gdrive-download.sh <Google_Drive_URL> [output_filename]
```

### Examples

**Download with automatic filename detection:**

```bash
./gdrive-download.sh "https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/view"
```

**Download with custom filename:**

```bash
./gdrive-download.sh "https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/view" "my_document.pdf"
```

**Different URL formats supported:**

```bash
# Standard sharing link
./gdrive-download.sh "https://drive.google.com/file/d/FILE_ID/view?usp=sharing"

# Open format
./gdrive-download.sh "https://drive.google.com/open?id=FILE_ID"

# Direct export link
./gdrive-download.sh "https://drive.google.com/uc?export=download&id=FILE_ID"
```

## Supported URL Formats

The script automatically recognizes and handles these Google Drive URL formats:

- `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`
- `https://drive.google.com/file/d/FILE_ID/view`
- `https://drive.google.com/open?id=FILE_ID`
- `https://drive.google.com/uc?export=download&id=FILE_ID`
- Any URL containing `id=FILE_ID` parameter

## File Access Requirements

**Important:** The Google Drive file must be publicly accessible or shared with "Anyone with the link" permissions. The script cannot download private files that require authentication.

To make a file publicly accessible:

1. Right-click the file in Google Drive
2. Select "Share" or "Get link"
3. Change permissions to "Anyone with the link"
4. Ensure "Viewer" or "Editor" access is selected
5. Copy the sharing link

## How It Works

1. **URL Parsing**: Extracts the file ID from various Google Drive URL formats
2. **Filename Detection**: Attempts to retrieve the original filename from Google Drive
3. **Initial Download**: Tries direct download for small files
4. **Large File Handling**: For large files, retrieves confirmation token and downloads with confirmation
5. **Verification**: Checks download success and displays file information

## Troubleshooting

### Common Issues

**"Error: Could not extract file ID from URL"**

- Ensure you're using a valid Google Drive sharing link
- Check that the URL contains the file ID
- Try copying the link again from Google Drive

**"Error: Failed to download file"**

- Verify the file is publicly accessible
- Check your internet connection
- Ensure the file hasn't been deleted or moved

**"Downloaded file is empty"**

- The file might be private or require special permissions
- Google Drive might be temporarily unavailable
- The file might have been deleted

**"Required tool 'X' is not installed"**

- Install the missing tool using your system's package manager
- See the Requirements section for installation commands

### Debug Mode

For troubleshooting, you can enable verbose output by modifying the wget commands in the script to remove the `--quiet` flag.

## File Size Limitations

Google Drive has different handling for files based on size:

- **Small files** (< 25MB): Direct download
- **Large files** (> 25MB): Require confirmation token (automatically handled)
- **Very large files** (> 5GB): May require special handling or multiple attempts

## Security Notes

- The script creates temporary files securely using `mktemp`
- Temporary cookies are automatically cleaned up
- No permanent cookies or authentication data is stored
- Only downloads files that are already publicly accessible

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Areas for Improvement

- Add support for downloading entire folders
- Implement resume capability for interrupted downloads
- Add progress bar for large downloads
- Support for batch downloads from a list of URLs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### v2.0.0

- Complete rewrite with improved error handling
- Added automatic filename detection
- Better support for large files
- Enhanced URL format recognition
- Added dependency checking
- Improved user interface and messages

### v1.0.0

- Initial release
- Basic Google Drive download functionality

## Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Search existing [GitHub issues](https://github.com/yourusername/gdrive-downloader/issues)
3. Create a new issue with detailed information about your problem

---

**Note**: This script is not affiliated with Google and uses publicly available Google Drive APIs. Make sure you comply with Google's Terms of Service when using this tool.
