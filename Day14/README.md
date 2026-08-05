# Day 14 – Networking Fundamentals & Hands-on Checks

## 📌 Overview

Networking is one of the most important foundations of DevOps. Every application, server, container, and cloud service communicates over a network. Understanding how data flows between systems and how to troubleshoot connectivity issues is an essential DevOps skill.

On **Day 14** of the **90 Days of DevOps Challenge**, I learned the fundamentals of computer networking, explored the **OSI Model** and **TCP/IP Model**, understood where common protocols operate, and performed several real-world networking troubleshooting commands.

---

# 🎯 Objectives

- Understand the OSI Model
- Learn the TCP/IP Model
- Compare OSI and TCP/IP architectures
- Identify where common protocols work
- Perform basic networking troubleshooting
- Verify connectivity, DNS, routing, ports, and HTTP responses
- Practice incident troubleshooting techniques

---

# 🌐 OSI Model

The **OSI (Open Systems Interconnection)** Model divides networking into **7 layers**, where each layer has a specific responsibility.

| Layer | Name | Responsibility |
|--------|------|----------------|
| Layer 7 | Application | Provides network services directly to end users and applications |
| Layer 6 | Presentation | Data translation, encryption, and formatting |
| Layer 5 | Session | Establishes, manages, and terminates communication sessions |
| Layer 4 | Transport | Provides end-to-end communication and reliable delivery |
| Layer 3 | Network | Handles logical addressing and routing |
| Layer 2 | Data Link | Provides node-to-node delivery and error detection |
| Layer 1 | Physical | Transmits raw bits through the physical medium |

---

# 🌍 TCP/IP Model

The TCP/IP model is the practical networking model used on the Internet.

| Layer | Responsibility |
|--------|----------------|
| Application | Interfaces with user applications such as browsers and email clients |
| Transport | End-to-end communication, segmentation, sequencing, and error checking |
| Internet | IP addressing and routing between different networks |
| Network Access | Physical transmission of data across the network |

---

# 🔄 OSI vs TCP/IP Mapping

| OSI Model | TCP/IP Model |
|-----------|--------------|
| Application | Application |
| Presentation | Application |
| Session | Application |
| Transport | Transport |
| Network | Internet |
| Data Link | Network Access |
| Physical | Network Access |

---

# 📡 Protocol Placement

| Protocol | OSI Layer | TCP/IP Layer | Purpose |
|----------|-----------|--------------|----------|
| IP | Layer 3 | Internet | Logical addressing and routing |
| TCP | Layer 4 | Transport | Reliable communication |
| UDP | Layer 4 | Transport | Fast, connectionless communication |
| HTTP | Layer 7 | Application | Web communication |
| HTTPS | Layer 7 | Application | Secure web communication |
| DNS | Layer 7 | Application | Converts domain names into IP addresses |

---

# 🛠 Hands-on Networking Checks

## 1. Identity Check

### Command

```bash
hostname -I
```

### Purpose

Displays the IP address assigned to the system.

---

## 2. Reachability Check

### Command

```bash
ping google.com
```

### Purpose

Verifies basic network connectivity and checks packet loss.

---

## 3. Path Analysis

### Command

```bash
traceroute google.com
```

### Purpose

Shows every hop taken by packets to reach the destination.

---

## 4. Open Ports Check

### Command

```bash
ss -tulpn
```

### Purpose

Displays active listening ports and associated processes.

---

## 5. DNS Resolution Check

### Command

```bash
nslookup google.com
```

### Purpose

Verifies whether DNS is resolving domain names correctly.

---

## 6. HTTP Check

### Command

```bash
curl -I https://google.com
```

### Purpose

Fetches only the HTTP response headers to verify web server availability.

---

## 7. Connection Snapshot

### Command

```bash
netstat -an | head
```

### Purpose

Displays current network connections and socket states.

---

# 🔍 Mini Task – Port Probe

### Listening Service

SSH Service

### Port

```
22
```

### Command

```bash
nc -zv localhost 22
```

### Purpose

Checks whether the SSH service is listening on port 22.

---

# 🧠 Reflection Questions

## Which command gives the fastest signal when something is broken?

**Answer**

```text
ping
```

**Reason**

It quickly verifies whether a remote system is reachable and identifies packet loss or latency issues.

---

## If DNS fails, which layer would you inspect?

### OSI Model

```
Layer 7 – Application Layer
```

### TCP/IP Model

```
Application Layer
```

### Reason

DNS operates at the Application Layer.

---

## If HTTP 500 appears, which layer would you inspect?

### OSI Model

```
Layer 7 – Application Layer
```

### TCP/IP Model

```
Application Layer
```

### Reason

HTTP 500 indicates a server-side application issue.

---

# 🚨 Real Incident Follow-up Checks

## Check 1

```bash
journalctl -xe
```

**Purpose**

Review system and service logs for errors and failures.

---

## Check 2

```bash
ss -tulpn
```

**Purpose**

Verify whether the required services are running and listening on the expected ports.

---

# 📚 Key Takeaways

- Learned the complete OSI Model and TCP/IP Model.
- Understood the mapping between OSI and TCP/IP layers.
- Identified where IP, TCP, UDP, HTTP, HTTPS, and DNS operate.
- Practiced connectivity testing using common Linux networking tools.
- Performed DNS, routing, HTTP, and port verification checks.
- Learned basic troubleshooting techniques used by DevOps Engineers and System Administrators.
- Understood how to diagnose common networking problems using Linux commands.

---

# 🏁 Conclusion

Day 14 focused on building a strong networking foundation required for DevOps. By understanding networking models, protocol layers, and troubleshooting commands, I gained practical experience in diagnosing connectivity issues, verifying services, and analyzing network behavior—skills that are essential for managing modern infrastructure and production environments.

---

## 👨‍💻 Author

**Aditya Sondekar**

### 90 Days of DevOps Challenge 🚀
