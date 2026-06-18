# PowerShell script for yt-dlp

clear-host

# Parse Config.json
$Config = Get-Content -Path "$PSScriptRoot\Config.json" | ConvertFrom-Json

# Set the ffmpeg path
if ($config.ffmpegPath -match "^[A-Za-z]:\\\\Users") {
    $ffmpegPath = $config.ffmpegPath
} else {
    $ffmpegPath = "$PSScriptRoot\ffmpeg"
}

# Set the output path
if ($config.outputPath -match "^[A-Za-z]:\\\\Users") {
    $outputPath = $config.outputPath
} else {
    $outputPath = "$PSScriptRoot\Output\%(title)s.%(ext)s"
}

# function to cut down on lines that just make it look better
function Spacing {
    Write-Host ""
    Write-Host ""
}

# yt-dlp download function
function Invoke-Download {
    param($format, $url)
    if ($format -eq "mp3" -or $format -eq "1") {
        .\yt-dlp.exe --ffmpeg-location $ffmpegPath -o $outputPath -x --audio-format mp3 "$url"
    } elseif ($format -eq "mp4" -or $format -eq "2") {
        .\yt-dlp.exe --ffmpeg-location $ffmpegPath -o $outputPath -f "bv*+ba/b" --merge-output-format mp4 "$url"
    }
    $script:downloadSucceeded = ($LASTEXITCODE -eq 0) # Set the download success flag
}

while ($true) {
    Spacing
    Write-Host "    -----------------------------"
    Write-Host "    |       yt-dlp script       |"
    Write-Host "    -----------------------------"
    Write-Host "    |        Version 1.6        |"
    Write-Host "    -----------------------------"
    Write-Debug "[DEBUG]    Script loaded successfully"
    Spacing

    # URL input
    $url = Read-Host "    Enter URL"
    Write-Debug "[DEBUG]    URL: $url"
    Spacing

    # Validate the URL
    if (-not ($url -like "*youtube.com*" -or $url -like "*youtu.be*")) {
        Write-Host "    Invalid URL. Please enter a YouTube URL. Ex: https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        Spacing
        break
    }
    
    # Format input
    $format = Read-Host "    Enter format (mp3 [1], mp4 [2])"
    Write-Debug "[DEBUG]    Format: $format"
    Spacing

    # Validate the format
    if ($format -ne "mp3" -and $format -ne "1" -and $format -ne "mp4" -and $format -ne "2") {
        Spacing
        Write-Host "    Invalid format '$format', please type either mp3 / 1 for mp3, or mp4 / 2 for mp4."
        continue
    }
    Write-Host "    Downloading..."
    Spacing
    Invoke-Download $format $url # Call the download function
    Spacing
    if ($downloadSucceeded) {
        Write-Host "    Download complete."
    } else {
        Write-Host "    Download failed."
        Spacing
        $choice = Read-Host "    Retry? (y/n)"
        if ($choice -eq "y") {
            Spacing
            Write-Host "    Retrying..."
            Spacing
            Invoke-Download $format $url
            Spacing
            if ($downloadSucceeded) {
                Write-Host "    Download complete."
            } else {
                Write-Host "    Download failed again. Aborting."
                Spacing
                break
            }
        } else {
            Spacing
            Write-Host "    Aborting..."
            Spacing
            break
        }
    }
    Spacing
    do {
        $choice = Read-Host "    Download another file? (y/n)"
        if ($choice -ne "y" -and $choice -ne "n") {
            Spacing
            Write-Host "    Invalid choice. Please enter 'y' for yes or 'n' for no."
            Spacing
        }
    } while ($choice -ne "y" -and $choice -ne "n")
    if ($choice -ne "y") {
        Spacing
        Write-Host "    Exiting..."
        Spacing
        break
    }
    clear-host
}