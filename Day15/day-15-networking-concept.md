# Day 15 - Networking Concept: DNS, IP, Subnets & Ports

## Task 1: DNS - How Names Become IPs.

### What happens when you type google.com in a browser ?

- Firstly, When we enter google.com in a browser first asks a DNS server to find IP associated with that Domain name.
- DNS translates the human readable name in to ip address.
- Once the ip is foud, the browser connects to the server and request the webpage.
- then the server responsed with webpage content.

### DNS record Type

| Record Type | Purpose |
|---------------|-------|
| A | Maps a domain name to an IPv4 address |
| AAAA | Maps a domain name to an IPv6 address |
| CNAME | Creates an alias from one domain name to another |
| MX | Specifies mail servers responsible for email delivery |
| NS | Identifies the authoritative name servers for a domain |
|----------|------------------|

#### Command: 
```bash
dig google.com
```
#### Output:
```text
;; ANSWER SECTION:
google.com.             137     IN      A       142.250.67.174
```

#### Findings:

- A Record: 142.250.67.174
- TTL: 137 Second

---

## Task 2: IP addressing

### What is an IPv4 Address?
```text
- An IPv4 address is a unique 32-bit numerical identifier assigned to devices on a network. It consists of four octets separated by dots, such as:

- 192.168.1.10

- Each octet ranges from 0 to 255.
```
### Public vs Private IP

#### Public IP
```text
A public IP is globally routable on the internet and assigned by an ISP.

Example:

8.8.8.8
```

#### Private IP
```text
A private IP is used within local networks and cannot be accessed directly from the internet.

Example:

192.168.1.10
```

#### Private IPv4 Ranges
```text
10.0.0.0 – 10.255.255.255
172.16.0.0 – 172.31.255.255
192.168.0.0 – 192.168.255.255
```

#### Command:
```bash
ip addr show
```

#### Sample Output
```text
inet 172.31.10.168/20 metric 100 brd 172.31.15.255 scope global dynamic ens5
```
#### Finding
```text
172.31.10.168/20 is a private IP address.
```

---

## Task 3: CIDR & Subnetting

### What does /24 mean in 192.168.1.0/24?
```text
The /24 indicates that the first 24 bits represent the network portion and the remaining 8 bits represent host addresses.
```

#### Subnet Mask:
```text
255.255.255.0
```

### Usable host

| CIDR | Subnet mask | total IPs | Usable host |
|-----|-----|------|
| /24 | 256 total IPs | 254 usable hosts |
| /16 | 65,536 total IPs | 65,534 usable hosts |
| /28 | 16 total IPs | 14 usable hosts |

### Why Do We Subnet?
```text
Subnetting divides a large network into smaller networks. It improves network management, enhances security, reduces broadcast traffic,
and helps efficiently use IP addresses.
```

---


## Task 4: Ports – The Doors to Services

### What is a Port?
```text
A port is a logical communication endpoint on a device. Ports allow multiple services to run on the same IP address by directing traffic to the
correct application.
```

| Common | Ports |
|--------|-------|
| Port | Service |
| 22 | SSH |
| 80 |	HTTP |
| 443 |	HTTPS |
| 53 |	DNS |
| 3306 | MySQL |
| 6379 | Redis |
| 27017 | MongoDB |
|-------|---------|

#### Command:
```bash
ss -tulpn
```

#### Sample output
```text
Netid          State           Recv-Q          Send-Q                        Local Address:Port                   Peer Address:Port          Process
udp            UNCONN          0               0                                 127.0.0.1:323                         0.0.0.0:*
udp            UNCONN          0               0                                127.0.0.54:53                          0.0.0.0:*
```

---

## Task 5: Putting It Together

### Q1. You run curl http://myapp.com:8080 — what networking concepts are involved?
```text
DNS first resolves myapp.com into an IP address. The client then connects to that IP using TCP on port 8080. Routing and networking ensure packets reach the destination server and receive a response.
```
### Q2. Your app can't reach a database at 10.0.1.50:3306 — what would you check first?
```text
I would verify network connectivity between the application and database server. Then I would check whether MySQL is listening on port 3306, confirm firewall/security group rules, and ensure the IP address is reachable.
```

#### Command Outputs
```bash
dig google.com
```

#### Output

```text
; <<>> DiG 9.20.18-1ubuntu2.1-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 29071
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             176     IN      A       142.251.42.238

;; Query time: 1 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sat Jun 13 10:44:25 UTC 2026
;; MSG SIZE  rcvd: 55
```

```bash
ss -tulpn
```

#### Output

```text
Netid          State           Recv-Q          Send-Q                        Local Address:Port                   Peer Address:Port          Process
udp            UNCONN          0               0                                 127.0.0.1:323                         0.0.0.0:*
udp            UNCONN          0               0                                127.0.0.54:53                          0.0.0.0:*
udp            UNCONN          0               0                             127.0.0.53%lo:53                          0.0.0.0:*
udp            UNCONN          0               0                        172.31.10.168%ens5:68                          0.0.0.0:*
udp            UNCONN          0               0                                     [::1]:323                            [::]:*
tcp            LISTEN          0               4096                                0.0.0.0:22                          0.0.0.0:*
tcp            LISTEN          0               4096                          127.0.0.53%lo:53                          0.0.0.0:*
tcp            LISTEN          0               4096                             127.0.0.54:53                          0.0.0.0:*
tcp            LISTEN          0               4096                                   [::]:22                             [::]:*

```
---

## What I Learned
- 1.DNS converts human-readable domain names into IP addresses so devices can communicate over networks.

- 2.CIDR notation and subnetting help organize networks efficiently and control IP allocation.

- 3.Ports allow multiple services such as SSH, HTTP, HTTPS, MySQL, and Redis to operate on the same machine simultaneously.

## Conclusion
```text
 Today I learned how DNS resolution works, how IPv4 addressing and private/public networks are structured, how subnetting helps manage networks efficiently,
 and how ports enable communication between services. These concepts form the foundation of networking knowledge required for DevOps and Cloud Engineering.
 ```
