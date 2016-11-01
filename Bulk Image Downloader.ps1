# script parameters, feel free to change it
$scriptDirectory = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$downloadFolder = $scriptDirectory + "\Downloaded Images\"
$bookmarkLocation = $scriptDirectory + "\" + "bookmarks.html"

# create a WebClient instance that will handle Network communications 
$webClient = New-Object System.Net.WebClient

# load System.Web so we can use HttpUtility
Add-Type -AssemblyName System.Web

# get the HTML from resulting search response
$webpage = Get-Content $bookmarkLocation

# use a 'fancy' regular expression to finds Urls terminating with '.jpg' or '.png'
$regex = "[(http(s)?):\/\/(www\.)?a-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-z0-9@:%_\+.~#?&//=]*)((.jpg(\/)?)|(.png(\/)?)){1}(?!([\w\/]+))"

$listImgUrls = $webpage | Select-String -pattern $regex -Allmatches | ForEach-Object {$_.Matches} | Select-Object $_.Value -Unique

# let's figure out if the folder we will use to store the downloaded images already exists
if((Test-Path $downloadFolder) -eq $false) 
{
    Write-Output "Creating '$downloadFolder'..."

    New-Item -ItemType Directory -Path $downloadFolder | Out-Null
}


foreach($imgUrlString in $listImgUrls) 
{
    [Uri]$imgUri = New-Object System.Uri -ArgumentList $imgUrlString

    # this is a way to extract the image name from the Url
    $imgFile = [System.IO.Path]::GetFileName($imgUri.LocalPath)

    # build the full path to the target download location
    $imgSaveDestination = Join-Path $downloadFolder $imgFile

    Write-Output "Downloading '$imgUrlString' to '$imgSaveDestination'..."

    $webClient.DownloadFile($imgUri, $imgSaveDestination)    
}