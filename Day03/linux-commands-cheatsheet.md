# Day 03 – Linux Commands Practice

## Process Management 

| Commands | Definition |
|----------|------------|
| ps aux | Display all the running process |
| top | Monitor system processes in real time |
| kill<PID> | Terminate Process using its PID |
| pkill <name> | kill processes by name | 
| pgrep <name> | Find Process Id by Process name | 

## File System Commands 

| Commands | Definition |
|----------|------------|
| pwd | Display current working directory |
| ls | List all the directory and Files |
| cd <dir> | change directory | 
| touch <filename> | create an File |
| cp <src> <dest> | Copying one file to another |
| mv <src> <dest> | move or rename file |
| rm -r<dir> | remove directory | 
| cat <filename> | Display the content In the file |
| df -h | display the disk space usage | 
| chmod | change file permission | 
| chown | changes file owner | 


## NetWorking and Troubleshooting 

| Command                    | Usage                                        |
| -------------------------- | -------------------------------------------- |
| `ping google.com`          | Test network connectivity.                   |
| `ip addr`                  | Display network interfaces and IP addresses. |
| `curl https://example.com` | Fetch data from a URL.                       |
| `dig google.com`           | Query DNS information.                       |
| `nslookup google.com`      | Look up DNS records.                         |
| `ss -tulnp`                | Show listening ports and active connections. |
| `netstat -tulnp`           | Display network statistics (legacy tool).    |
| `traceroute google.com`    | Trace packet route to a host.                |
| `wget <url>`               | Download files from the internet.            |
| `hostname -I`              | Display local IP address.                    |


