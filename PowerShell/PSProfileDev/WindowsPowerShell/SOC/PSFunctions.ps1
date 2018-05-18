<#-- 

PSFuntions Library

This is a collection of misc functions J.D. has written.  Each function will have comments and/or 
instructions.

--#>


<#-- InitVars and DestructVars should be called at the beginning and end of scripts.  They will make sure that
any variables created during the script run are properly destroyed.
--#>

# Store all the start up variables to facilitate clean up with the DestructVars() function when the script finishes.
Function Initialize-Variables{
    if ($startVars) { try {Remove-Variable -Name startVars  -Scope Global -ErrorAction SilentlyContinue } catch { } }
    New-Variable -force -name startVars -value ( Get-Variable | ForEach-Object { $_.Name } ) 
}
Set-Alias -Name InitVars -Value Initialize-Variables -Description "Get existing variables for constructor"

# Check if admin shell
function Check-Admin {
    # Check current "RunAs" and elevate to administrator if needed then re-execute

    # Get the UID and principal of the current user account
    $userUID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prnID=new-object System.Security.Principal.WindowsPrincipal($userUID)

    # Get the security principal for the Administrator role
    $admRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    # Check to see if we are currently running "as Administrator"
    if ($prnID.IsInRole($admRole)) 
        {
        # We are! Change the title and background color to indicate this
        $Host.UI.RawUI.WindowTitle = "Windows PowerShell (ELEVATED)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $host.ui.RawUI.ForegroundColor="Red"

        Clear-Host
        return $true
        }
    else
        {
        return $false
        }
    }

Function Convert-FileTime{
    param([Int64]$ToConvert)
    
    if ( ($ToConvert -eq 0) -or ($ToConvert -gt [DateTime]::MaxValue.Ticks) )
        {$AcctExpires = "<Never>"}
    else
        {$AcctExpires = [DateTime]::FromFileTime($ToConvert)}

    Return $AcctExpires
    }

function cowsay($msg) {
    if (! $msg) {
    $msg = motd
    }
    $(Invoke-Webrequest https://helloacm.com/api/cowsay/?msg="$msg").content | ConvertFrom-Json
    }

# Call this to destroy all variables not defined in $startVars
Function Destruct-Variables {
    Get-Variable | Where-Object { $startVars -notcontains $_.Name } |
    ForEach-Object {
        try { 
            Remove-Variable -Name "$($_.Name)" -Force -Scope "global" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            }
        catch {
            ;; 
            }
        }
    }
Set-Alias -Name DestructVars -Value Destruct-Variables -Description "Clear all variables created since last InitVars"


# This will properly throw an error and destroy all created variables.  Similar to the Perl Die command.
Function Die {
    param([string]$ErrMsg,[string]$PSError)

    Write-Warning -Message $ErrTxt
    Write-Warning -Message $PSError
    DestructVars($startvars)
    exit 1
}

Function Get-DateInfo {
    $lNow =  Get-Date
    $uTime = Get-Date -uformat %s
    $GMTnow = $lNow.toUniversalTime()
    }

Function Get-LocInfo {
    $TZAPIKey = "AIzaSyCAhEl2cV1F8_bMknlz2sBkcp6Nz9ly2g4"

    $GPSURL = "http://maps.googleapis.com/maps/api/geocode/json?components=postal_code:" + $user.PostalCode
    $ZIPRequest= Invoke-WebRequest $GPSURL | ConvertFrom-Json

    $Lat=$ZIPRequest.results.geometry.location.lat
    $Lng = $ZIPRequest.results.geometry.location.lng

    $TZURL = "https://maps.googleapis.com/maps/api/timezone/json?location=$Lat,$Lng&timestamp=$uTime&key=$TZAPIKey"
    $TZRequest = Invoke-WebRequest $TZURL | ConvertFrom-Json
    $GMTOffset = ($TZRequest.rawOffset+$TZRequest.dstOffset)/3600
    }

function motd {
    $MOTD=$(Invoke-WebRequest https://helloacm.com/api/fortune/).content | ConvertFrom-Json
    return $MOTD
    }

Function Run-AsAdmin
    {
    # Check RunAs and elevate to administrator if not already

    # Get the UID and principal of the current user account
    $userUID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prnID=new-object System.Security.Principal.WindowsPrincipal($userUID)
 
    # Get the security principal for the Administrator role
    $admRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
    # Check to see if we are currently running "as Administrator"
    if ($prnID.IsInRole($admRole))
       {
       # We are running "as Administrator" - so change the title and background color to indicate this
       $Host.UI.RawUI.WindowTitle = $myProc.MyCommand.Definition + "(Elevated)"
       $Host.UI.RawUI.BackgroundColor = "DarkBlue"
       clear-host
       }
    else
       {
       # We are not running "as Administrator" - so relaunch as administrator   
       # Create a new process object that starts PowerShell
       Write-Error "Not running as administrator...  Elevating."
       $newProc = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
       # Get current script name for re-execute
       $newProc.Arguments = $myProc.MyCommand.Definition;
   
       # Indicate that the process should be elevated
       $newProc.Verb = "runas";
   
       # Start the new process
       [System.Diagnostics.Process]::Start($newProc);
   
       # Exit from the current, unelevated, process
       exit
       }
    }







