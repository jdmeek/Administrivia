$ZipFile = "$Home\Downloads\Splunk-ResKit-PowerShell.zip"

$progressPreference = 'silentlyContinue'    # Subsequent calls do not display UI.
Invoke-WebRequest https://github.com/splunk/splunk-reskit-powershell/archive/master.zip -OutFile $ZipFile

Expand-Archive $ZipFile -DestinationPath $Temp\Splunk-ResKit-PS