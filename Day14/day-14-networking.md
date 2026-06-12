# Day 14 - Networking Fundamentals & Hands-on Checks:

## OSI Model:

| Layers | Name | Responsibilites |
|--------|------|-----------------|
| Layer 1 | Physical Layer | Establish physical connection between devices and transmit raw bit |
| Layer 2 | Data Link Layer | Provides nodes-to-to delivery and error detection/correction/
| Layer 3 | Network Layer | Handles Logical addressing and routing of data between Different networks | 
| Layer 4 | Transport layer | Ensure end to end communication |
| Layer 5 | Session layer | Establish, manages and terminates communication session between application | 
| Layer 6 | Presentation layer | Translates, encrpyts, and Format data for application layer |
| Layer 7 | Application Layer | Provides Network Service Directly to end user |
|---------|--------|

---

## TCP/IP Model:

| Layers | responsibilities |
| Application layer | The top layer closest to the user, where application like web browers and email clients interact with the network using protocol. |
| Transport layer | Responsible for end-to-end communication, ensuring reliable data delivery through segmentation, sequencing, and error checking. |
| Internet layer | Handles logical addressing (IP addresses) and routing, determining the best path for data packets to travel across different networks. |
| Network access layer | Manages the physical transmission of data bits over the network medium. | 
|----------|----------|

---

## Mapping:

| OSI |	TCP/IP |
|-----|--------|
| Application |	Application |
| Presentation | Application |
| Session	| Application |
| Transport | Transport |
| Network |	Internet |
| Data Link | Link |
| Physical | Link |
|-------|--------|

--- 

## Protocol Placement

### IP
- Works at Network Layer (OSI L3)
- Internet Layer in TCP/IP

### TCP / UDP
- Works at Transport Layer (OSI L4)
- Transport Layer in TCP/IP

### HTTP / HTTPS
- Works at Application Layer (OSI L7)
- Application Layer in TCP/IP

### DNS
- Works at Application Layer (OSI L7)
- Used for hostname to IP resolution

---

## Hands-on Networking Checks:

### 1. Identity check

#### Command:

```bash
hostname -I
```

### Output and Screenshot:

![Hostname](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/de784f069d578d907e6b5a6a03bd20e8d923133a/images/14%20task%201.png)

---

### 2.Reachability check:

#### Command:

```bash
ping google.com
```

### Output and screenshot:

![ping](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/de784f069d578d907e6b5a6a03bd20e8d923133a/images/14%20task%202.png)

---

### 3.Path analysis

#### Command:

```bash
traceroute google.com
```

#### Output and Screenshot:

![traceroute](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/de784f069d578d907e6b5a6a03bd20e8d923133a/images/14%20task%203.png)

---

### 4. Open Ports Check:

#### Command:

```bash
ss -tulpn
```

#### Output and Screenshot:

![ss -tulpn](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/de784f069d578d907e6b5a6a03bd20e8d923133a/images/14%20task%204.png)

---

### 5. DNS Resolution check

#### Command:

```bash
nslookup google.com
```

#### Output and Screenshot:

![nslookup](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/de784f069d578d907e6b5a6a03bd20e8d923133a/images/14%20task%205.png)

---

### 6. Http check 

#### Command:

```bash
curl -I https://google.com
```

#### Output and Screenshot:

![curl](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/de784f069d578d907e6b5a6a03bd20e8d923133a/images/14%20task%206.png)

---

### 7. Connection snapshot

#### Command:

```bash
netstat -an | head
```
#### Output and Screenshot:

![netstat](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/de784f069d578d907e6b5a6a03bd20e8d923133a/images/14%20task%207.png)

---

## Mini Task: Port Probe & Interpret:

### Listening Service

```text
SSH Service

port:22

```

#### Command

```bash
nc -zv localhost 22
```

#### Output and Screeshot:

![](https://github.com/Workwithaditya01/90DaysOfDevOps/blob/de784f069d578d907e6b5a6a03bd20e8d923133a/images/14%20task%208.png)

---

## Reflection

### Which command gives the fastest signal when something is broken?

- ping

- Reason: Quickly confirms basic network connectivity and packet loss.


### If DNS Fails, Which Layer Would You Inspect?

#### OSI:

- Layer 7 (Application)

#### TCP/IP:

- Application Layer

- Reason: DNS is an application-layer protocol.


### If HTTP 500 Appears, Which Layer Would You Inspect?

#### OSI:

- Layer 7 (Application)

#### TCP/IP:

- Application Layer

- Reason: HTTP 500 indicates a server-side application issue.


## Two Follow-up Checks During a Real Incident

### Check 1

```bash
journalctl -xe
```

- Review service and system logs.

### Check 2

```bash
ss -tulpn
```

- Verify service ports and listening processes.

---

## Key Takeaways

- Learned OSI and TCP/IP model mapping.
- Identified where DNS, HTTP, TCP, UDP, and IP operate.
- Performed connectivity, DNS, HTTP, routing, and port checks.
- Validated service availability using netstat, ss, and nc.
- Practiced a real-world troubleshooting workflow used in DevOps and System Administration.

---


