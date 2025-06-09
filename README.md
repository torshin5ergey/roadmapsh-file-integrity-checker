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


- [ ] Accept a directory or a single log file as input.
- [ ] Utilize a cryptographic hashing algorithm, such as SHA-256, to compute hashes for each log file provided.
- [ ] On first use, store the computed hashes in a secure location.
- [ ] For subsequent uses, compare the newly computed hashes against the previously stored ones.
- [ ] Clearly report any discrepancies found as a result of the hash comparison, indicating possible file tampering.
- [ ] Allow for manual re-initialization of log file integrity.
- [ ] ./integrity-check init /var/log  # Initializes and stores hashes of all log files in the directory
- [ ] ./integrity-check check /var/log/syslog > Status: Modified (Hash mismatch) # Optionally report the files where hashes mismatched
- [ ] > ./integrity-check -check /var/log/auth.log > Status: Unmodified
- [ ] > ./integrity-check update /var/log/syslog > Hash updated successfully.

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
2. Run the script
```bash
./integrity-check.sh
```

### Usage

### Examples

## Author

Sergey Torshin [@torshin5ergey](https://github.com/torshin5ergey)
