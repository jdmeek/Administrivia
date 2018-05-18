<#--
.ExternalHelp 
--#>

# Load VB object support
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

# Init the shell object we're executing in.
$Shell = $Host.UI.RawUI

# Set a usable date variable
$Date = get-date -UFormat %m-%d-%Y

# Init user variables
$User=$ENV:USERNAME
$HostName = hostname
$Temp = $env:TMP

# Define UDir pointing to the hidden user properties directory
$UDir = $PSDir+"\.UProps"
$CacheDir = $UDir+"\Cache"

# Check history file 
$HistoryFile = $UDir+"\pshistory.xml"

#Check for history file and load if exists
if (Test-path $HistoryFile)
{   
    Import-CliXML $HistoryFile | Add-History
}

# This refreshes the .pshistory file on exiting a session
Register-EngineEvent PowerShell.Exiting -SupportEvent -Action {   
    Get-History -Count $MaximumHistoryCount | Export-CliXML $HistoryFile > $null
    exit
}



# Import custom functions
. $SOCLibDir\PSFunctions.ps1
. $SOCLibDir\SOC-Functions.ps1

# Load custom SOC object formats
Update-FormatData -AppendPath $SOCLibDir\SOCTypes.Format.ps1xml

# Setup some nifty shell hacks
# Decorate window accordingly if admin privs.
$ADMPrivs = Check-Admin

    # Set Custom Window Title
    If ($PS2) 
    {
        $Shell.WindowTitle=$PS2
    }
    