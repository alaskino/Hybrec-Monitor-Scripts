<#
    Script Name: DisplayTextScript.ps1
    Description: This script allows users to send custom text to a display system with configurable color, brightness, blinking, and display time for Hybrec Monitors.
    Created by: Mathieu Licata
    Creation Date: 16/01/2025

    Purpose: This script was created purely for personal curiosity and experimentation.
    It is not intended for commercial purposes or to modify products from Hybrec.
    The author does not claim any rights over Hybrec's products, services, or intellectual property.
    This is simply a personal project to explore display text manipulation via HTTP requests.

    Requirements:
    - PowerShell 5.1 or higher
    - Access to the target device's API (accessible via URL)
    - Input parameters: Text to display, colors, brightness, blinking, and time for display

    Usage:
    - Run the script in a PowerShell terminal.
    - You will be prompted to enter the text, color(s), brightness, blink behavior, and time for display.
    - The script will send the specified settings to the target device.

    Contact Information:
    - Email: matthew2958@gmail.com
    - GitHub: https://github.com/alaskino/

    Disclaimer:
    - This script is provided "as-is" with no warranties. Use it at your own risk.
    - The author is not responsible for any damages or issues arising from the use of this script.

    Version History:
    - 1.0 - Initial version

    Check README file for more infos.
#>
# URL
$url = "http://192.168.XXX.XXX/gendata/impostazioni.html" # URL for English products, be careful as it might change.
$word = Read-Host "Enter the word or phrase you want to display:" # Ask the user for the word or phrase to display.

Write-Host "Enter colors (separated by commas) choosing from: red, yellow, green, blue, white, cyan, magenta" # Ask for the colors, multiple colors can be chosen by separating them with commas.
$colorsInput = Read-Host "Colors"
$colors = $colorsInput -split ',' | ForEach-Object { $_.Trim() }

$validColors = @("red", "yellow", "green", "blue", "white", "cyan", "magenta") # List of valid colors.
if (-not ($colors | ForEach-Object { $_ -in $validColors })) {
    Write-Host "Invalid colors were entered. The script will use the default color: red."
    $colors = @("red")
}

$brightnessInput = Read-Host "Choose the brightness (max, middle, min)" # Ask for the brightness level.
$brightness = "max" # Default setting
if ($brightnessInput -eq "max") {
    $brightness = "max"
} elseif ($brightnessInput -eq "min") {
    $brightness = "min"
}

$blinkInput = Read-Host "Do you want the text to blink? (yes/no)" # Ask if the text should blink.
$blink = $false
if ($blinkInput -eq "yes") {
    $blink = $true
} elseif ($blinkInput -eq "no") {
    $blink = $false
}

$timechooseInput = Read-Host "Choose the time in seconds (max 99) or 'endless'" # Ask for the display time.
$timechoose = 0 # Endless
if ($timechooseInput -eq "endless") {
    $timechoose = 0
} elseif ($timechooseInput -match '^\d+$' -and [int]$timechooseInput -le 99) {
    $timechoose = [int]$timechooseInput
} else {
    Write-Host "Invalid time, set to endless."
}

function BuildJson($file01Value, $color, $color2, $brightness, $blink, $timechoose) { # Function to build the JSON payload.
    return @"
{
    "NtpServer": [
        {
            "Address": "ntp1.inrim.it",
            "QueryTime": "60",
            "LastUpdate": ""
        }
    ],
    "Brightness":"$brightness",
    "VisualIp": "1",
    "Font": "5",
    "Font2": "5",
    "Communication": "2",
    "Weather": "0",
    "DateFormat": "1",
    "Color": "blue",
    "TimePage": "$timechoose",
    "Row": [
        {
            "File01":"$file01Value",
            "Color01":"$color",
            "Blink01":$blink
        },
        {
            "File02": "Line 2",
            "Color02":"$color2",
            "Blink02":false
        },
        {
            "File03": "Line 3",
            "Color03": "yellow",
            "Blink03": false
        },
        {
            "File04": "Line 4",
            "Color04": "yellow",
            "Blink04": false
        }
    ],
    "NewTime": "",
    "NewDate": "",
    "Signal": ""
}
"@
}

while ($true) {
    try {
        for ($i = 0; $i -lt $word.Length; $i++) {
            $file01Value = $word.Substring($i, [math]::Min(2, $word.Length - $i))
            $color = $colors[$i % $colors.Length]
            $color2 = $colors[($i + 1) % $colors.Length]
            $jsonData = BuildJson $file01Value $color $color2 $brightness $blink $timechoose
            $response = Invoke-RestMethod -Uri $url -Method POST -Body $jsonData -ContentType "application/json" -Headers @{
                "Accept" = "application/json"
            }
            # Write-Output "Sent: $file01Value with color: $color and $color2" # Output (optional)
            Start-Sleep -Seconds 0.6 # Dont go under 0.6 cause it is fast af.
        }
    } catch {
        Write-Error "Error: $_"
    }
}
