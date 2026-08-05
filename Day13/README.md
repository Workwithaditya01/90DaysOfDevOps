# Day 13 – Linux Volume Management (LVM) on AWS EC2

## 📌 Objective

Learn how Linux Logical Volume Management (LVM) works by creating, managing, mounting, and extending storage using an AWS EC2 instance with an attached Amazon EBS volume.

---

# 📖 What is LVM?

**Logical Volume Management (LVM)** is a storage management solution in Linux that provides flexibility in allocating and managing disk space. Unlike traditional partitions, LVM allows storage to be resized, extended, and managed dynamically without repartitioning disks.

LVM is widely used in production environments because it simplifies storage management and supports future storage expansion.

---

# 🏗️ LVM Architecture

```text
AWS EBS Volume
      │
      ▼
Physical Volume (PV)
      │
      ▼
Volume Group (VG)
      │
      ▼
Logical Volume (LV)
      │
      ▼
Filesystem (EXT4)
      │
      ▼
Mount Point
```

---

# 🚀 Challenge Tasks

## Task 1 – Check Current Storage

### Commands

```bash
lsblk
pvs
vgs
lvs
df -h
```

### Description

- Checked available disks and partitions.
- Verified existing Physical Volumes.
- Verified existing Volume Groups.
- Verified existing Logical Volumes.
- Checked mounted filesystems and available storage.

### Outcome

Identified the newly attached AWS EBS volume that would be configured using LVM.

---

## Task 2 – Create Physical Volume (PV)

### Commands

```bash
pvcreate /dev/xvdf
pvs
```

### Description

Initialized the attached AWS EBS volume as a Physical Volume so it could be managed by LVM.

### Outcome

Successfully created and verified the Physical Volume.

---

## Task 3 – Create Volume Group (VG)

### Commands

```bash
vgcreate devops-vg /dev/xvdf
vgs
```

### Description

Created a Volume Group named **devops-vg** using the Physical Volume.

### Outcome

Successfully created a storage pool for creating Logical Volumes.

---

## Task 4 – Create Logical Volume (LV)

### Commands

```bash
lvcreate -L 500M -n app-data devops-vg
lvs
```

### Description

Created a 500 MB Logical Volume named **app-data** from the available space in the Volume Group.

### Outcome

Successfully created a Logical Volume ready for formatting.

---

## Task 5 – Format and Mount the Logical Volume

### Commands

```bash
mkfs.ext4 /dev/devops-vg/app-data

mkdir -p /mnt/app-data

mount /dev/devops-vg/app-data /mnt/app-data

df -h /mnt/app-data
```

### Description

- Formatted the Logical Volume using the EXT4 filesystem.
- Created a mount directory.
- Mounted the Logical Volume.
- Verified the mounted filesystem.

### Outcome

The Logical Volume became available for storing application data.

---

## Task 6 – Extend the Logical Volume

### Commands

```bash
lvextend -L +200M /dev/devops-vg/app-data

resize2fs /dev/devops-vg/app-data

df -h /mnt/app-data
```

### Description

- Increased the Logical Volume size by 200 MB.
- Expanded the filesystem to use the newly allocated space.
- Verified the updated storage capacity.

### Outcome

Successfully extended the storage without recreating partitions or causing downtime.

---

# 📚 Commands Used

```bash
sudo -i

lsblk
pvs
vgs
lvs
df -h

pvcreate /dev/xvdf

vgcreate devops-vg /dev/xvdf

lvcreate -L 500M -n app-data devops-vg

mkfs.ext4 /dev/devops-vg/app-data

mkdir -p /mnt/app-data

mount /dev/devops-vg/app-data /mnt/app-data

df -h /mnt/app-data

lvextend -L +200M /dev/devops-vg/app-data

resize2fs /dev/devops-vg/app-data

df -h /mnt/app-data
```

---

# 🧠 Key Concepts Learned

- Understanding LVM architecture (PV → VG → LV)
- Working with AWS EBS volumes
- Creating Physical Volumes
- Creating Volume Groups
- Creating Logical Volumes
- Formatting Linux filesystems
- Mounting storage volumes
- Extending Logical Volumes
- Resizing filesystems
- Dynamic storage management in Linux

---

# 🎯 Advantages of LVM

- Dynamic storage expansion
- Better disk space management
- No need to repartition disks
- Supports snapshots
- Easy storage administration
- Combines multiple disks into a single storage pool
- Suitable for production environments

---

# 💡 Real-World Use Cases

- Expanding application storage without downtime
- Managing cloud storage in AWS EC2
- Database storage management
- Enterprise Linux servers
- Virtual machine storage management
- Production DevOps infrastructure

---

# 📖 Key Takeaways

- LVM provides flexible and scalable storage management.
- Physical Volumes are created from storage devices such as AWS EBS volumes.
- Volume Groups combine one or more Physical Volumes into a storage pool.
- Logical Volumes act as flexible partitions created from the Volume Group.
- Filesystems are created on Logical Volumes before mounting.
- Storage can be extended dynamically without affecting existing data.

---

# 📝 Conclusion

On Day 13 of the **90 Days of DevOps Challenge**, I gained practical experience with **Linux Logical Volume Management (LVM)** using an **AWS EC2 instance** and an attached **Amazon EBS volume**. I successfully created a Physical Volume, Volume Group, and Logical Volume, formatted and mounted the storage, and later extended the volume without downtime. This hands-on exercise strengthened my understanding of Linux storage management and demonstrated how LVM is used in real-world cloud and production environments.
