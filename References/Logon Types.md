# Logon Types



## Column Definitions:

Logon type - Identifies the logon type initiated by the connection.
Reusable credentials on destination - Indicates that the following credential types will be stored in LSASS process memory on the destination computer where the specified account is logged on locally:
LM and NT hashes
Kerberos TGTs
Plaintext password (if applicable).
The symbols in this table defined as follows:

(-) denotes when credentials are not exposed.
(v) denotes when credentials are exposed.

  
   

| Connection method                                | Logon type            | Reusable credentials on destination | Comments                                                                                                                                      |
| ------------------------------------------------ | --------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Log on at console                                | Interactive           | v                                   | Includes hardware remote access / lights-out cards and network KVMs.                                                                          |
| RUNAS                                            | Interactive           | v                                   |                                                                                                                                               |
| RUNAS /NETWORK                                   | NewCredentials        | v                                   | Clones current LSA session for local access, but uses new credentials when connecting to network resources.                                   |
| Remote Desktop (success)                         | RemoteInteractive     | v                                   | If the remote desktop client is configured to share local devices and resources, those may be compromised as well.                            |
| Remote Desktop (failure - logon type was denied) | RemoteInteractive     | -                                   | By default, if RDP logon fails credentials are only stored briefly. This may not be the case if the computer is compromised.                  |
| Net use \* \\\SERVER                             | Network               | -                                   |                                                                                                                                               |
| Net use \* \\\SERVER /u:user                     | Network               | -                                   |                                                                                                                                               |
| MMC snap-ins to remote computer                  | Network               | -                                   | Example: Computer Management, Event Viewer, Device Manager, Services                                                                          |
| PowerShell WinRM                                 | Network               | -                                   | Example: Enter-PSSession server                                                                                                               |
| PowerShell WinRM with CredSSP                    | NetworkClearText      | v                                   | <p>New-PSSession server<br>-Authentication Credssp<br>-Credential cred</p>                                                                    |
| PsExec without explicit creds                    | Network               | -                                   | Example: PsExec \\\server cmd                                                                                                                 |
| PsExec with explicit creds                       | Network + Interactive | v                                   | <p>PsExec \\server -u user -p pwd cmd<br>Creates multiple logon sessions.</p>                                                                 |
| Remote Registry                                  | Network               | -                                   |                                                                                                                                               |
| Remote Desktop Gateway                           | Network               | -                                   | Authenticating to Remote Desktop Gateway.                                                                                                     |
| Scheduled task                                   | Batch                 | v                                   | Password will also be saved as LSA secret on disk.                                                                                            |
| Run tools as a service                           | Service               | v                                   | Password will also be saved as LSA secret on disk.                                                                                            |
| Vulnerability scanners                           | Network               | -                                   | Most scanners default to using network logons, though some vendors may implement non-network logons and introduce more credential theft risk. |

For web authentication, use the reference from the table below:

| Connection method                       | Logon type                                                                    | Reusable credentials on destination | Comments                     |
| --------------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------- | ---------------------------- |
| IIS "Basic Authentication"              | <p>NetworkCleartext<br>(IIS 6.0+)</p><p>Interactive<br>(prior to IIS 6.0)</p> | v                                   |                              |
| IIS "Integrated Windows Authentication" | Network                                                                       | -                                   | NTLM and Kerberos Providers. |



  
  
  
  

## Column definitions:

* **Logon type** - The type of logon requested.
* **#** - The numeric identifier for the logon type that is reported in audit events in the Security event log.
* **Authenticators accepted** - Indicates which types of authenticators are able to initiate a logon of this type.
* **Reusable credentials in LSA session** - Indicates whether the logon type results in the LSA session holding credentials, such as plaintext passwords, NT hashes, or Kerberos tickets that could be used to authenticate to other network resources.
* **Examples** - List of common scenarios in which the logon type is used.



| Logon type                                 | #  | Authenticators accepted                         | Reusable credentials in LSA session                                 | Examples                                                                                                                                                                   |
| ------------------------------------------ | -- | ----------------------------------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Interactive (also known as, Logon locally) | 2  | <p>Password, Smartcard,<br>other</p>            | Yes                                                                 | <p>Console logon;<br>RUNAS;<br>Hardware remote control solutions (such as Network KVM or Remote Access / Lights-Out Card in server)<br>IIS Basic Auth (before IIS 6.0)</p> |
| Network                                    | 3  | <p>Password,<br>NT Hash,<br>Kerberos ticket</p> | No (except if delegation is enabled, then Kerberos tickets present) | <p>NET USE;<br>RPC calls;<br>Remote registry;<br>IIS integrated Windows auth;<br>SQL Windows auth;</p>                                                                     |
| Batch                                      | 4  | Password (stored as LSA secret)                 | Yes                                                                 | Scheduled tasks                                                                                                                                                            |
| Service                                    | 5  | Password (stored as LSA secret)                 | Yes                                                                 | Windows services                                                                                                                                                           |
| NetworkCleartext                           | 8  | Password                                        | Yes                                                                 | <p>IIS Basic Auth (IIS 6.0 and newer);<br>Windows PowerShell with CredSSP</p>                                                                                              |
| NewCredentials                             | 9  | Password                                        | Yes                                                                 | RUNAS /NETWORK                                                                                                                                                             |
| RemoteInteractive                          | 10 | <p>Password, Smartcard,<br>other</p>            | Yes                                                                 | Remote Desktop (formerly known as "Terminal Services")                                                                                                                     |






Ref: https://docs.microsoft.com/en-us/windows-server/identity/securing-privileged-access/reference-tools-logon-types
