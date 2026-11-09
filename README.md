# Espanso — Security / IR / Offensive Toolkit

A set of [Espanso](https://espanso.org/) match files for blue team (SOC / IR / DFIR),
red team / pentest, and everyday productivity use.

## Installation

**macOS / Linux:** run the installer from the repo folder:

```
./install.sh            # copy the files into Espanso's match folder and restart Espanso
./install.sh --link     # symlink instead, so edits in this repo apply straight away
./install.sh --dry-run  # show what it would do
```

It finds the folder with `espanso path`, backs up any different file already in the way
(as `<name>.yml.bak-<timestamp>`, which Espanso ignores), and never overwrites an
installed `shared-vars.yml`. That file is always copied, never linked, so the personal
values you put in it stay out of the repo.

**Windows, or by hand:** copy all `.yml` files into your Espanso match directory:

| OS      | Path                                          |
|---------|-----------------------------------------------|
| Windows | `%APPDATA%\espanso\match\`                    |
| macOS   | `~/Library/Application Support/espanso/match/` |
| Linux   | `~/.config/espanso/match/`                    |

Not sure which folder your install uses? `espanso path` prints the config
folder; the match files go in its `match/` subfolder.

Then reload Espanso:
```
espanso restart
```

---

## Files

| File                 | Contents                                                          |
|----------------------|---------------------------------------------------------------------|
| `shared-vars.yml`    | Centralized values (org name, analyst info, SOC contact, ticket prefix) imported by other files — not installed on its own, see below |
| `timestamps.yml`     | Date/time triggers — UTC, ISO, local time, epoch, weekday          |
| `ioc.yml`            | IOC blocks, hash templates, defang, threat-intel portal links      |
| `incidents.yml`      | Incident headers, timelines, playbooks, comms, post-incident docs  |
| `signatures.yml`     | Email signatures — standard, IR, short, OOO                        |
| `swedish.yml`        | Swedish signatures, OOO, incident notice, status report, phishing reply |
| `cli.yml`            | PowerShell, Azure CLI, KQL, Windows/Linux/macOS host-triage commands |
| `detection.yml`      | Hunting queries — KQL (Sentinel / Defender XDR) and Splunk SPL     |
| `email.yml`          | Phishing triage — header checklist, verdict, reporter reply, purge |
| `cloud.yml`          | AWS and GCP security / audit CLI commands                          |
| `network.yml`        | Wireshark/tshark filters, tcpdump, DNS lookups, port reference     |
| `kubernetes.yml`     | kubectl auditing, container image scanning, Dockerfile hardening   |
| `secrets.yml`        | Secret scanning, dependency auditing, SAST                         |
| `encoding.yml`       | URL / hex / base32 / JWT / HTML entity encode-decode, email defang |
| `vulnmgmt.yml`       | CVSS/EPSS/KEV references, patch and risk-acceptance templates      |
| `compliance.yml`     | GDPR/PCI-DSS notices, SOC2/ISO27001 references, audit templates    |
| `pentest.yml`        | Offensive security / ethical hacking commands and payloads         |
| `wireless-mobile.yml`| Wireless (aircrack-ng) and mobile (adb/APK) security commands      |
| `forensics.yml`      | DFIR — evidence handling, memory/disk forensics, YARA/Sigma        |
| `ctf.yml`            | CTF flag/encoding helpers and a writeup template                   |
| `nice-to-have.yml`   | General productivity — quick replies, symbols, small utilities     |

---

## Shared values (`shared-vars.yml`)

`signatures.yml`, `ioc.yml`, `incidents.yml`, `email.yml` and `swedish.yml` pull identity/contact fields
(your name, title, org, SOC phone, legal contact, MISP URL, ticket prefix)
from `shared-vars.yml` via Espanso's `imports:` mechanism instead of
repeating `[placeholder]` text in every template. **Edit `shared-vars.yml`
once** and every trigger that uses `{{org_name}}`, `{{analyst_name}}`, etc.
picks up the change.

`shared-vars.yml` has no `matches:` of its own — install it alongside the
other files, but it only does something when another file in the same
directory imports it (each importing file already has the `imports:` line
pointing at it).

---

## ⚠️ Authorized Use Only

`pentest.yml` and `wireless-mobile.yml` contain offensive security commands
(scanners, exploitation frameworks, reverse shells, password-cracking,
payload generation, wireless deauth/capture). These are provided for
**authorized** penetration testing engagements, red team exercises, and CTF
competitions only. Always confirm signed scope / rules of engagement before
running anything from those files against a target or network you do not
own or are not explicitly authorized to test.

---

## Quick Reference

### Timestamps
| Trigger       | Output                          |
|---------------|----------------------------------|
| `:date`       | 28 Mar 2026                      |
| `:utc`        | 28 Mar 2026 14:00 UTC (real UTC)  |
| `:iso`        | 2026-03-28T14:00:00Z (real UTC)   |
| `:isolocal`   | 2026-03-28T14:00:00 (no offset)   |
| `:dateiso`    | 2026-03-28                        |
| `:time`       | 14:00                             |
| `:ts12`       | 2:00 PM                           |
| `:dow`        | Saturday                          |
| `:year`       | 2026                              |
| `:weekno`     | 13 (ISO week number)              |
| `:epoch`      | Unix epoch seconds                |
| `:timewindow` | Incident time window placeholder  |

### IOC / Threat Intel
| Trigger        | Output                              |
|-----------------|--------------------------------------|
| `:defip`        | Defang IP from clipboard             |
| `:defurl`       | Defang URL from clipboard            |
| `:refang`       | Refang IOCs from clipboard           |
| `:iocblock`     | Full IOC documentation block         |
| `:hashblock`    | MD5 / SHA1 / SHA256 block            |
| `:rfc1918`      | Private IP range reference           |
| `:vt`           | VirusTotal search URL                |
| `:mdesha`       | MDE file hash portal URL             |
| `:shodan`       | Shodan search URL                    |
| `:abuseipdb`    | AbuseIPDB lookup URL                 |
| `:urlscan`      | urlscan.io search URL                |
| `:misp`         | MISP event search URL                |
| `:otx`          | AlienVault OTX indicator URL         |
| `:talos`        | Cisco Talos reputation lookup URL    |
| `:cveurl`       | NVD CVE detail page URL              |
| `:threatintel`  | Threat intelligence summary block    |

### Secrets & Code Security
| Trigger              | Output                                |
|------------------------|------------------------------------------|
| `:gitleaksscan`        | Full repo secret scan (gitleaks)         |
| `:gitleaksstaged`      | Pre-commit staged secret scan            |
| `:trufflehogscan`      | Verified secret scan (TruffleHog)        |
| `:gitsecrethistory`    | Grep secret keywords across git history  |
| `:npmaudit`            | npm dependency audit                     |
| `:pipaudit`            | Python dependency audit                  |
| `:semgrepscan`         | Semgrep SAST scan (auto config)          |
| `:sastreport`          | SAST / code review finding template      |

### Encoding / Decoding
| Trigger        | Output                                      |
|-----------------|--------------------------------------------|
| `:urlencode`    | URL-encode a string (PowerShell)            |
| `:urldecode`    | URL-decode a string (PowerShell)            |
| `:hexencode`    | String → hex (PowerShell)                   |
| `:hexdecode`    | Hex → string (PowerShell)                   |
| `:b32enc`       | Base32 encode (Python)                      |
| `:b32dec`       | Base32 decode (Python)                      |
| `:htmlencode`   | HTML entity encode (PowerShell)             |
| `:htmldecode`   | HTML entity decode (PowerShell)             |
| `:jwtdecode`    | Decode a JWT payload                        |
| `:defemail`     | Defang an email address from clipboard      |

### Vulnerability Management
| Trigger         | Output                                     |
|------------------|--------------------------------------------|
| `:cvsscalc`      | CVSS v3.1 calculator URL                    |
| `:epssref`       | EPSS reference URL                          |
| `:kevref`        | CISA KEV catalog URL                        |
| `:patchticket`   | Patch management ticket template            |
| `:vulnreport`    | Vulnerability scan report summary template  |
| `:riskaccept`    | Risk acceptance / exception request template|

### Compliance / Audit
| Trigger         | Output                                     |
|------------------|--------------------------------------------|
| `:gdprclock`     | GDPR 72-hour breach notification reminder   |
| `:pcidss`        | PCI-DSS cardholder data compromise notice   |
| `:soc2ref`       | SOC 2 trust service criteria reference      |
| `:isocontrol`    | ISO 27001 control mapping template          |
| `:auditfinding`  | Audit finding template                      |
| `:dpia`          | DPIA (Data Protection Impact Assessment) stub |

### Incidents & Tickets
| Trigger          | Output                              |
|-------------------|--------------------------------------|
| `:inchead`        | Incident header block                |
| `:tl`              | Single timeline row                  |
| `:timeline`        | Timeline table with header           |
| `:contain`         | Containment checklist                |
| `:sitrep`          | Status update template               |
| `:fp`              | False positive closure note          |
| `:tp`              | True positive escalation note        |
| `:mitre`           | MITRE ATT&CK inline tag              |
| `:sev`             | Severity / CVSS rating line          |
| `:assets`          | Affected assets block                |
| `:phishreport`     | Phishing report intake template      |
| `:ransomplaybook`  | Ransomware initial response checklist|
| `:commstemplate`   | Stakeholder communication template   |
| `:lessons`         | Post-incident review template        |
| `:escalation`      | Escalation matrix reference          |
| `:breachnotif`     | Regulatory breach notification draft |
| `:legalhold`       | Legal hold notice template           |
| `:rootcause`       | Root cause analysis template         |
| `:sevmatrix`       | Severity / priority definitions      |

### Email / Phishing Triage
| Trigger         | Output                                          |
|-----------------|--------------------------------------------------|
| `:hdrcheck`     | Header analysis checklist                       |
| `:hdrgrep`      | grep the key headers out of a `.eml`            |
| `:phishverdict` | Triage verdict for the ticket                   |
| `:phishreply`   | Reply to the person who reported it             |
| `:phishpurge`   | Purview compliance search + purge               |

### Signatures
| Trigger    | Output                           |
|------------|-----------------------------------|
| `:sig`     | Full professional signature (uses `shared-vars.yml`) |
| `:sigs`    | Short inline signature (uses `shared-vars.yml`)      |
| `:sigir`   | IR-specific signature + notice (uses `shared-vars.yml`) |
| `:sigooo`  | Out-of-office escalation footer (uses `shared-vars.yml`) |

### Swedish / Svenska
| Trigger       | Output                                              |
|---------------|------------------------------------------------------|
| `:svsig`      | Signatur, standard (motsvarar `:sig`)               |
| `:svirsig`    | Signatur för incidenthantering (`:sigir`)           |
| `:svooo`      | Frånvaromeddelande (`:sigooo`)                      |
| `:svincident` | Incidentmeddelande till ledning/personal (`:commstemplate`) |
| `:svlage`     | Lägesrapport under pågående incident (`:sitrep`)    |
| `:svphish`    | Svar till den som rapporterat ett mejl (`:phishreply`) |

### CLI — Blue Team / Host Triage
| Trigger         | Output                                     |
|------------------|---------------------------------------------|
| `:psgraph`       | Connect-MgGraph                             |
| `:pssignin`      | Get-MgAuditLogSignIn for a UPN              |
| `:psrevoke`      | Revoke-MgUserSignInSession                  |
| `:psdisable`     | Disable Entra ID account                    |
| `:psmfa`         | Get MFA methods for user                    |
| `:psrole`        | Get directory role members                  |
| `:mdeisolate`    | MDE device isolation (REST API)             |
| `:mdeunisolate`  | Release MDE device from isolation           |
| `:mdelive`       | MDE live response script (REST API)         |
| `:azlogin`       | az login with tenant                        |
| `:azsub`         | az account set subscription                 |
| `:azrole`        | az role assignment list                     |
| `:azdiag`        | az monitor diagnostic-settings list         |
| `:azactivity`    | az monitor activity-log export              |
| `:azstorage`     | az storage account public access check      |
| `:kqlstart`      | Generic KQL query stub                      |
| `:kqlsignin`     | SigninLogs failed logins stub               |
| `:kqlalert`      | SecurityAlert high/critical stub            |
| `:kqlproc`       | DeviceProcessEvents process stub            |
| `:b64enc`        | PowerShell Base64 encode                    |
| `:b64dec`        | PowerShell Base64 decode                    |
| `:sha256`        | Get-FileHash SHA256                         |
| `:grepip`        | Grep IP addresses from log file             |
| `:logtail`       | tail -f with timestamps                     |
| `:netstat`       | netstat ESTABLISHED connections             |
| `:psaux`         | ps aux sorted by CPU (Linux)                |
| `:lsof`          | Listening sockets by process (Linux)        |
| `:defenderscan`  | Trigger full Defender scan                  |
| `:defenderupdate`| Force Defender signature update             |
| `:fwrules`       | List enabled firewall rules                 |
| `:schtasks`      | List enabled scheduled tasks                |
| `:localadmins`   | List local Administrators group members     |
| `:winevents`     | Recent Security event log entries           |
| `:sharesenum`    | Enumerate SMB shares                        |
| `:procnetconn`   | Established TCP connections + process       |
| `:svcenum`       | List running services                       |
| `:maclogshow`    | Search the unified log (`/usr/bin/log show`) |
| `:maclogcollect` | Collect the unified log as evidence         |
| `:macpersist`    | Non-Apple launch agents/daemons             |
| `:macbtm`        | Background Task Management dump (13+)       |
| `:macprofiles`   | Installed configuration profiles            |
| `:macquarantine` | Download history (quarantine events DB)     |
| `:mactcc`        | Privacy (TCC) grants; needs Full Disk Access |
| `:macsign`       | Code signature, notarisation, xattrs        |
| `:macsecstatus`  | SIP, Gatekeeper, FileVault status           |
| `:macnet`        | Established TCP connections + process       |
| `:macusers`      | Local user accounts                         |

### Detection — KQL / SPL
| Trigger           | Output                                           |
|-------------------|---------------------------------------------------|
| `:kqlmfafatigue`  | Repeated MFA failures per user per hour          |
| `:kqlnewcountry`  | Sign-in from a country new for the user (14 days) |
| `:kqlconsent`     | OAuth consent grants                             |
| `:kqlinboxrule`   | New / changed inbox rules                        |
| `:kqlmailfrom`    | All mail from one sender (campaign scope)        |
| `:kqlurlclick`    | Who clicked a URL (Safe Links)                   |
| `:kqlencps`       | Encoded PowerShell command lines                 |
| `:kqlnetconn`     | Devices that connected to an IP                  |
| `:kqlfilehash`    | Where a SHA256 was seen                          |
| `:splstart`       | Generic SPL search stub                          |
| `:splioc`         | Where an indicator appears (by index/sourcetype) |
| `:splfailedlogon` | Failed logons (4625) by source                   |
| `:splproc`        | Sysmon process creation on a host                |
| `:splencps`       | Encoded PowerShell (Sysmon)                      |

### Cloud (AWS / GCP)
| Trigger              | Output                                    |
|-----------------------|----------------------------------------------|
| `:awswhoami`          | aws sts get-caller-identity                  |
| `:awsiamusers`        | List IAM users                               |
| `:awsiamkeys`         | List access keys for a user                  |
| `:awss3public`        | Check S3 bucket ACL                          |
| `:awss3block`         | Check S3 public-access-block config          |
| `:awscloudtrail`      | Look up CloudTrail events for a user         |
| `:awsguardduty`       | List GuardDuty findings                      |
| `:awssg`              | Find security groups open to 0.0.0.0/0       |
| `:awsassumerole`      | Assume an IAM role                           |
| `:awsconfigcompliance`| AWS Config compliance summary                |
| `:gcpauth`            | gcloud auth login                            |
| `:gcpproject`         | Set active GCP project                       |
| `:gcpiam`             | Get project IAM policy                       |
| `:gcplogging`         | Read Cloud Logging entries                   |
| `:gcpassets`          | Search all resources in a project            |
| `:gcpbucketiam`       | Check bucket IAM configuration               |
| `:gcpscc`             | List Security Command Center findings        |

### Network
| Trigger          | Output                                  |
|-------------------|--------------------------------------------|
| `:wsdns`          | Wireshark DNS display filter               |
| `:wshttp`         | Wireshark HTTP/TLS handshake filter        |
| `:wsbeacon`       | Wireshark beaconing/SYN filter             |
| `:wscreds`        | Wireshark cleartext credential filter      |
| `:tsharkhttp`     | tshark HTTP field extraction               |
| `:tcpdumpcap`     | tcpdump — write capture to file            |
| `:tcpdumpfilter`  | tcpdump — host/port filter                 |
| `:diglookup`      | dig A record lookup                        |
| `:digmx`          | dig MX record lookup                       |
| `:digns`          | dig NS record lookup                       |
| `:nslookupptr`    | nslookup PTR (reverse) lookup              |
| `:traceroute`     | traceroute (Linux/macOS)                   |
| `:tracert`        | tracert (Windows)                          |
| `:curlheaders`    | curl — response headers only               |
| `:curlfollow`     | curl — follow redirects, headers only      |
| `:portref`        | Common ports reference table               |

### Kubernetes / Containers
| Trigger            | Output                                    |
|---------------------|------------------------------------------------|
| `:kubectlpods`      | List all pods, all namespaces                  |
| `:kubectlpriv`      | Find privileged containers                     |
| `:kubectlrbac`      | List cluster role bindings                     |
| `:kubectlsecrets`   | List secrets, all namespaces                   |
| `:kubectlexec`      | Exec into a pod                                |
| `:kubectllogs`      | Get previous-container logs                    |
| `:kubectlevents`    | List cluster events, sorted                    |
| `:trivyscan`        | Scan container image (Trivy)                   |
| `:grypescan`        | Scan container image (Grype)                   |
| `:dockerhistory`    | Show image layer history                       |
| `:dockerinspect`    | Inspect a container                            |
| `:dockerps`         | List containers, untruncated                   |
| `:dockerhardening`  | Dockerfile hardening checklist                 |

### Pentest / Offensive Security
| Trigger          | Output                                        |
|-------------------|-------------------------------------------------|
| `:scopecheck`     | Scope/ROE reminder                              |
| `:nmapquick`      | Quick nmap version scan (top 1000 ports)        |
| `:nmapfull`       | Full TCP port + service/script scan             |
| `:nmapudp`        | UDP top-100 scan                                |
| `:nmapvuln`       | nmap vuln script scan                           |
| `:whatweb`        | WhatWeb fingerprinting                          |
| `:niktoscan`      | Nikto web server scan                           |
| `:smbenum`        | SMB share / user enumeration                    |
| `:searchsploit`   | searchsploit lookup                             |
| `:gobuster`       | Directory brute-force                           |
| `:ffuf`           | Web fuzzing                                     |
| `:sqlmap`         | SQL injection testing                           |
| `:sqlipayload`    | Basic SQLi payload                              |
| `:xssalert`       | Basic reflected-XSS payload                     |
| `:lfipayload`     | Basic LFI path traversal payload                |
| `:hydrassh`       | SSH password spray (hydra)                      |
| `:hydrahttp`      | HTTP POST form password spray (hydra)           |
| `:hashcatntlm`    | NTLM hash cracking                              |
| `:hashcatbcrypt`  | bcrypt hash cracking                            |
| `:johncrack`      | John the Ripper wordlist crack                  |
| `:msfconsole`     | Metasploit console one-liner                    |
| `:msfvenom`       | Windows meterpreter payload generation          |
| `:revshellbash`   | Bash reverse shell                              |
| `:revshellnc`     | Netcat reverse shell                            |
| `:revshellpy`     | Python3 reverse shell                           |
| `:revshellpwsh`   | PowerShell reverse shell                        |
| `:linpeas`        | Linux privilege-escalation enumeration          |
| `:winpeas`        | Windows privilege-escalation enumeration        |
| `:sudocheck`      | List sudo privileges                            |
| `:suidfind`       | Find SUID binaries                              |
| `:crontabread`    | Review cron persistence                         |
| `:responder`      | LLMNR/NBT-NS poisoning                          |
| `:bloodhound`     | AD attack path collection                       |
| `:crackmapexec`   | SMB credential validation / enumeration         |
| `:reportfind`      | Pentest finding report template                 |

### Wireless / Mobile
| Trigger          | Output                                    |
|-------------------|------------------------------------------|
| `:airmoninfo`     | List wireless interfaces (airmon-ng)      |
| `:airmonstart`    | Enable monitor mode                       |
| `:airodump`       | Capture wireless traffic                  |
| `:aireplay`       | Deauth attack                             |
| `:aircrack`       | Crack handshake capture (wordlist)        |
| `:hcxdump`        | Capture with hcxdumptool                  |
| `:hcxconvert`     | Convert capture to hashcat format         |
| `:adbdevices`     | List connected Android devices            |
| `:adbpull`        | Pull files from device                    |
| `:adbshell`       | Open adb shell                            |
| `:adbpackages`    | List installed third-party packages       |
| `:apkinfo`        | Dump APK manifest info                    |
| `:apkdecomp`      | Decompile an APK                          |

### Forensics / DFIR
| Trigger            | Output                                          |
|---------------------|---------------------------------------------------|
| `:coc`              | Chain of custody template                         |
| `:evidlog`          | Evidence log entry template                       |
| `:hashverify`       | Verify evidence image hash (Windows)               |
| `:ddimage`          | Disk imaging with dd                               |
| `:dcfldd`           | Disk imaging with hashing (dcfldd)                 |
| `:ftkimage`         | FTK Imager CLI acquisition                         |
| `:volpslist`        | Volatility — process list                          |
| `:volpstree`        | Volatility — process tree                          |
| `:volnetscan`       | Volatility — network connections                   |
| `:volmalfind`       | Volatility — injected code detection               |
| `:voldump`          | Volatility — dump files for a PID                  |
| `:plaso`            | Build super-timeline (log2timeline)                |
| `:psort`            | Export timeline to CSV                             |
| `:evtxparse`        | Parse Windows Event Log to CSV                     |
| `:prefetchparse`    | Parse Prefetch (PECmd)                             |
| `:amcacheparse`     | Parse Amcache hive                                 |
| `:shimcache`        | Parse AppCompatCache / ShimCache                   |
| `:regripper`        | Parse registry hive with RegRipper                 |
| `:sysmonproc`       | Sysmon process-creation KQL stub                   |
| `:timelineentry`    | Single forensic timeline row                       |
| `:artifactloc`      | Common Windows artifact locations reference        |
| `:yarascan`         | Run YARA rules against a path                      |
| `:yarastub`         | YARA rule skeleton                                 |
| `:sigmastub`        | Sigma rule skeleton                                |

### CTF
| Trigger            | Output                               |
|---------------------|--------------------------------------|
| `:flagformat`       | `flag{}` skeleton                    |
| `:encchain`         | Common encoding chain to try         |
| `:stringsflag`      | Grep strings output for "flag"       |
| `:binwalkextract`   | Extract embedded files (binwalk)     |
| `:steghideextract`  | Extract hidden data (steghide)       |
| `:exiftoolread`     | Read image metadata                  |
| `:ctfwriteup`       | CTF writeup template                 |

### Nice to Have
| Trigger    | Output                                    |
|------------|---------------------------------------------|
| `:ty`      | "Thank you!"                                 |
| `:lmk`     | "Let me know if you have any questions."     |
| `:brb`     | Stepping away note                           |
| `:flw`     | "Following up on this — "                    |
| `:apw`     | "Apologies for the delay — "                 |
| `:eta`     | ETA placeholder line                         |
| `:greet`   | Email greeting                               |
| `:close`   | Email closing                                |
| `:recap`   | Meeting recap template                       |
| `:cal`     | Meeting scheduling blurb                     |
| `:addr`    | Postal address template                      |
| `:phone`   | Phone number placeholder                     |
| `:arrow`   | →                                            |
| `:check`   | ✅                                            |
| `:cross`   | ❌                                            |
| `:warn`    | ⚠️                                            |
| `:bullet`  | • (bullet + space)                           |
| `:em`      | — (em dash)                                  |
| `:todo`    | "TODO: "                                     |
| `:genpw`   | Random 20-character password (shell)         |
| `:uuid`    | New GUID/UUID (shell)                        |
| `:d`       | Current date, short form                     |

---

## Notes

- **`shared-vars.yml`**: set `org_name`, `analyst_name`, `analyst_title`, `analyst_email`, `analyst_phone`, `soc_phone`, `legal_contact`, `misp_instance`, and `ticket_prefix` once — `signatures.yml`, `ioc.yml`, `incidents.yml`, `email.yml` and `swedish.yml` all pick the values up automatically via `imports:`.
- **`:defip` / `:defurl` / `:defemail` / `:refang`** read the clipboard with a shell command. Switch between `pbpaste` (macOS) and `xclip` (Linux) by commenting/uncommenting the appropriate `cmd` line in `ioc.yml` / `encoding.yml`. Defanging is safe to repeat (already-defanged text isn't double-bracketed).
- **`:utc` / `:iso`** use Espanso's `tz: "UTC"` option, which needs Espanso 2.3.0 or later; older versions silently print local time.
- **`:mdeisolate` / `:mdeunisolate` / `:mdelive`** call the Defender for Endpoint REST API and expect a bearer token in `$token`.
- **`:genpw` / `:uuid`** use shell commands that work on macOS and Linux (`/dev/urandom`, `uuidgen`). On Windows, switch to the commented PowerShell `cmd` lines in `nice-to-have.yml`.
- **Short triggers that start longer ones** (`:d`, `:date`, `:iso`, `:time`, `:timeline`, `:sig`, `:sev`) are word triggers: type a space, Enter or punctuation after them to expand. Without this, Espanso would expand `:d` before you could finish typing `:date` or `:defip`.
- **Signatures**: Any field not covered by `shared-vars.yml` (team name, PGP key, backup contact) is still a plain `[placeholder]` to fill in per use.
- **`pentest.yml` / `wireless-mobile.yml`**: replace `TARGET` / `ATTACKER_IP` / `TARGET_BSSID` / wordlist paths before running, and only against systems and networks you are authorized to test — see [Authorized Use Only](#-authorized-use-only) above.
- All triggers use `:` prefix to avoid accidental expansion mid-word.

## License

MIT — see [LICENSE](LICENSE).
