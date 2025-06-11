# 🔒 File Integrity Checker Project for [roadmap.sh](https://roadmap.sh/)

This is my solution to the [File Integrity Checker project](https://roadmap.sh/projects/file-integrity-checker) in the [DevOps roadmap](https://roadmap.sh/devops) from [roadmap.sh](https://roadmap.sh/)

**Table of Contents**
- [References](#references)
- [Project Requirements](#project-requirements)
- [Prerequisites](#prerequisites)
- [How To Use](#how-to-use)
  - [Usage](#usage)
  - [Examples](#examples)
- [Author](#author)

## References

- [man sha256sum](https://www.man7.org/linux/man-pages/man1/sha256sum.1.html)
- [Build a simple CLI with Bash](https://dev.to/adiatma/build-a-simple-cli-with-bash-2d31)

## Project Requirements

- [x] Accept a directory or a single log file as input.
- [x] Utilize a cryptographic hashing algorithm, such as SHA-256, to compute hashes for each log file provided.
- [x] On first use, store the computed hashes in a secure location.
- [x] For subsequent uses, compare the newly computed hashes against the previously stored ones.
- [x] Clearly report any discrepancies found as a result of the hash comparison, indicating possible file tampering.
- [x] Allow for manual re-initialization of log file integrity.
- [x] ./integrity-check init /var/log  # Initializes and stores hashes of all log files in the directory
- [x] ./integrity-check check /var/log/syslog > Status: Modified (Hash mismatch) # Optionally report the files where hashes mismatched
- [x] > ./integrity-check -check /var/log/auth.log > Status: Unmodified
- [x] > ./integrity-check update /var/log/syslog > Hash updated successfully.

## Prerequisites

- Linux OS (AlamLinux 9.5 Minimal)

## How To Use

0. Clone the repository
```bash
git clone https://github.com/torshin5ergey/roadmapsh-file-integrity-checker
cd roadmapsh-file-integrity-checker
```
1. Ensure the `integrity-check.sh` script is executable
```bash
chmod +x integrity-check.sh
```
2. Run the script (example)
```bash
./integrity-check.sh init /var/log/nginx/
```

### Usage

```bash
integrity-check.sh [COMMAND] [TARGET] [OPTIONAL_HASH_FILE]

Commands:
  init      Create new integrity baseline
  check     Verify against stored baseline
  update    Update existing baseline
  help      Show usage information

Arguments:
  TARGET             Directory or file to monitor
  OPTIONAL_HASH_FILE Custom hash file location (default: ~/.log-integrity/hashes.sha256)
```

### Examples

- Initialize hash file for Nginx logs
```bash
sudo ./integrity-check.sh init /var/log/nginx/
# Output
Hashes stored successfully in /root/.log-integrity/hashes.sha256
2 files monitored.
```
- Check single file integrity
```bash
sudo ./integrity-check.sh check /var/log/nginx/access.log
# Output
Status: Unmodified.
```
- Check directory contents
```bash
sudo ./integrity-check.sh check /var/log/nginx/
# Output
Modified file: /var/log/nginx/error.log
New file: /var/log/nginx/new.log
Status: Modified.
```
- Update hash file after legitimate changes
```bash
sudo ./integrity-check.sh update /var/log/nginx/
# Output
Status: hash file /root/.log-integrity/hashes.sha256 updated.
```
- Init custom hash file:
```bash
./integrity-check.sh init ~/app-logs /opt/security/app-hashes.sha256
# Output
Hashes stored successfully in /opt/security/app-hashes.sha256.
```

## Author

Sergey Torshin [@torshin5ergey](https://github.com/torshin5ergey)
