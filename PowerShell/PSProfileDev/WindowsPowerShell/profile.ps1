<#--
SOC Env

A J.D. project that can only be explained as a psychosis induced 
effort to make everyday SOC analyst tasks faster and to provide
a common frame-work for a more harmonious community.

This is a baseline profile for SOC team members.

All of your profile options should be configured from here. This
file will overload any public(context) options set by the libraries.

If you screw around in those files, the gods will be pissed and ninjas
will eat your babies and


There is a hidden directory called .uprops that contains working files
such as your history file.  These files are for maintaining session and object
state and shouldn't even be considered as part of the universe unless your PS-Fu
is undeniable.

You may need to set your local execution policy before any of this, or any other
PowerShell script can be used.  To verify this setting, and set it if needed, you
can run the following command.  You will need to allow an administrative action so
you will likely be prompted to login to for this to complete.

if (! $(Get-ExecutionPolicy -eq 'RemoteSigned' AND Get-ExecutionPolicy -eq 'Unrestricted')) 
{Set-ExecutionPolicy -Scope CurrentUser RemoteSigned}

More documentation is forth coming via >>get-help about=soclib.
I will let you know when that's available.

For bug reports or feature requests, please email me at jd.meek@premisehealth.com

If you enjoy the environmnent I've built, please let me know that I'm not working
in vain by sending me an email saying something nice about your mother.
--#>


###################################################################################
# This section is critical for initializing the environment.  It must be executed #
# first.  Please do not edit anything in the INIT section.  Doing so              #
# Will likely screw the pooch and JD will be annoyed if he has to unscrew a pooch #
# because you couldn't/wouldn't/didn't ask.                                       #
###################################################################################


<#--INIT--#>
$Version="1.0"

$ErrorActionPreference = "SilentlyContinue"

# Define the PSDir variable since MS didn't find it necessary to
$PSDir = $profile | Split-Path

# Import custom functions and variables
# This should always be at the top of your
# Local Profile script.
$SOCLibDir="$PSDir\SOC"

# Set maximum size of the history file
$MaximumHistoryCount = 10KB

#Check SOC Env Profile related paths
if (!(Test-Path $SOCLibDir -PathType Container))
{   
    Write-Error "SOCLib isn't properly configured. ERROR: Unable to locate SOCLibDir ($SOCLibDir)."
    Write-Error "Press Any Key To Exit or Ctrl+C to continue with standard PS shell."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
    exit 5
}

. $SOCLibDir/SOC-Env.ps1

# Set starting directory to the users local profile
Set-Location $HOME

<#--END INIT and finish it all pretty like...--#>

Write-Host "PowerShell SOC Environment $Version ( PSVer:"$PsVersionTable.PSVersion")`n"

<#-- Command Aliases and Filters
This section is used to define command aliases and filters.

Command aliases allow you to use rename commands or functions and add default parameters.
Filters are like functions but process pipeline input data faster

Filter Descriptions:
Grep is a search command.  To use this filter, simply pipe your search data to grep
with a keyword to search for.  For example
    gc textfile.txt | grep keyword
    
Sed is a search and replace command.  To use this, simply pipe your output to sed with 
the string to replace and the replacement value.  For example
    gc textfile.txt | sed before after
--#>

filter grep($keyword) { if ( ($_ | Out-String) -like "*$keyword*") { $_ } }
filter sed($before,$after) { %{$_ -replace $before,$after} }

<#-- Engage random amusement functionality --#>
cowsay