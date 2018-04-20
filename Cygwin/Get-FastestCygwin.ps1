#requires -version 2
<#
.SYNOPSIS
  This script will determine the fastest Cygwin Mirror for your location.

.DESCRIPTION
  This script will determine the fastest Cygwin Mirror for your location.

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  NONE

.OUTPUTS
  Displays the 10 fastest cygwin hosts

.NOTES
  Version:        1.1
  Author:         J.D. Meek
  Creation Date:  01-03-2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  Get-FastestCygwin
#>

<#--
App Notes:
    Without switches, this script will determine the fastest Cygwin Mirror for your location.
    If you add the -install switch, it will download cygwin-setup-x64 and will start a manual installation.
    If you add the -install -silent switch, it will look for the cygwin-install.def file.  If not found, a
    basic install will be performed.

    http://cygwin.com/mirrors.html
    
These are the original bash commands that spawned this.   
    system("cat mirrors.html | grep -A500 'Site list by region' | grep -B500 'Mirror Administrators' | sed -e s/\\ /\\\\n/g | sed -e s/\\,/\\\\n/g  > tmp.1");
    system("cat tmp.1 | sed -e s/\\</\\\\n/g | grep href | grep -v 'rsync' | cut -f 2 -d \\\" | sort | uniq > cygwin_mirror.list ");
--#>


#---------------------------------------------------------[Initialisations]-------------------------------------------------------


#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = 'SilentlyContinue'

$Debug = 1

$Results = @()
$StartDir = Get-Location
$WorkDir = "$Env:AppData\CygDiscover"

if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64")
    {
    $Arch = "x86_64"
    }
    else
    {
    $Arch = "x86"
    }

if (Test-Path $WorkDir) {
    try {
        Remove-Item -Recurse -Force $WorkDir
        }
        catch
        {
        Write-Error "Unable to clear the existing work directory.`n Please ensure that another copy of this script is not running."
        Exit 1
        }

}

New-Item $WorkDir -ItemType Directory
Set-Location $WorkDir

$Mirrors = Invoke-WebRequest -TimeoutSec 1 http://cygwin.com/mirrors.html 
$URLS = $Mirrors.Links | where {($_.innerHTML -Match 'com$|net$|org$') -AND ($_.href -NotMatch 'rsync:|ftp:')} | Select outerText,href

foreach ($BASE in $URLS)
     {

     Remove-Variable $Time

     $URI = $BASE.href + $Arch + "/setup.xz"

     $Site = $BASE.href.split("/",4)
     $HostName = $Site[2]

     Write-Host -NoNewline -ForegroundColor Green "Checking $HostName... " 
     
     try 
        {
	$Time = Measure-Command {$URITime = Invoke-WebRequest --TimeoutSec 1 $URI}
	Write-Output -ForegroundColor Yellow $Time
	}
        catch
        {
        if ($Debug) {
            Write-Error -ForegroundColor Red "Failed!"
	    $Time.Ticks = 10000
            }
        }

     $TmpObj = New-Object PSObject 
     $TmpObj | Add-Member -type NoteProperty -Name HostName -Value $HostName
     $TmpObj | Add-Member -type NoteProperty -Name URL -Value $URI.Replace("setup.xz","")
     $TmpObj | Add-Member -type NoteProperty -Name Ticks -Value $Time.Ticks

     $Results += $TmpObj
     }

$TopTen = $Results | Sort Ticks | Select -First 10

Write-Host "Fastest Host: $TopTen[0].HostName"

Write-Host "Would you like to fetch the latest installer and start using this host?"
while("yes","no","y","n" -notcontains $answer)
{
	$answer = Read-Host "Yes or No"
}

if ($answer -eq "YES" -or $Answer -eq "Y") {
<#--
Setup Command Line Options:
 -A --disable-buggy-antivirus           Disable known or suspected buggy anti
                    virus software packages during execution.
 -C --categories                        Specify entire categories to install
 -D --download                          Download from internet
 -d --no-desktop                        Disable creation of desktop shortcut
 -h --help                              print help
 -K --pubkey                            Path to extra public key file (gpg format)
 -L --local-install                     Install from local directory
 -l --local-package-dir                 Local package directory
 -n --no-shortcuts                      Disable creation of desktop and start menu
                    shortcuts
 -N --no-startmenu                      Disable creation of start menu shortcut
 -O --only-site                         Ignore all sites except for -s
 -P --packages                          Specify packages to install
 -p --proxy                             HTTP/FTP proxy (host:port)
 -q --quiet-mode                        Unattended setup mode
 -r --no-replaceonreboot                Disable replacing in-use files on next
                    reboot.
 -R --root                              Root installation directory
 -S --sexpr-pubkey                      Extra public key in s-expr format
 -s --site                              Download site
 -U --keep-untrusted-keys               Use untrusted keys and retain all
 -u --untrusted-keys                    Use untrusted keys from last-extrakeys
 -X --no-verify                         Don't verify setup.ini signatures
--#>

    $CygRoot = $(Get-ItemProperty HKLM:\SOFTWARE\Cygwin\setup).rootdir
    $SetupFile="setup-$Arch.exe"
    $WorkSetup = "$Workdir\$SetupFile"
    Write-Host "Fetching Setup File."
    Invoke-WebRequest --TimeoutSec 1 "http://cygwin.org/$SetupFile" -OutFile $WorkSetup
    Write-Host "Done...  Executing."

    $CygArgs = "--root $CygRoot --quiet-mode --upgrade-also --site $Fastest"

    Invoke-Expression "$WorkSetup $CygArgs"
    }

if ($ShowTopTen) {
    Write-Host "Top Ten`n`n$TopTen"
    }

Set-Location $StartDir

$ErrorActionPreference = "Continue"
$progressPreference = 'Continue' 

exit 
