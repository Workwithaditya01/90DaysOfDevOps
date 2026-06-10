# Day 13 - Linux Volumn Management(LVM)

## Objective
- Learn Linux Logical Volume Management (LVM) to create, manage, extend, and mount storage volumes dynamically.

## What is LVM?
- LVM (Logical Volume Manager) is a storage management system in Linux that provides flexibility compared to traditional disk partitions.

## LVM Components?

### Physical Component(PV)
- Actual Storage Disk.

### Volume Group(VG)
- Pool of Storage created from one or more Physical Volumes.

### Logical Volume(LV)
- Virtual partition created from a Volumn Group.

---

## Task 1: Create Current Storage 

### Commands:

```bash
lsblk - Display block devices.
```
```bash
pvs - Show Physical volume.
```
```bash
vgs - Show volumn group.
```
```bash
lvs - show logical volumn.
```
```bash
df-h - Display mounted file system and disk usage.
```

### Screenshot
![Command image][https://github.com/Workwithaditya01/90DaysOfDevOps/blob/1c768dfa4920834bb645edb69f3cfb38628654ec/images/13%20task%201.png]

---

## Task 2: Create a Physical Volume

### Command:

```bash
pvcreate /dev/nvme1n1
```

### Verification:

```bash
pvdisplay
```
#### OR

```bash
lsblk
```

### Screenshot
![Physical Volume][https://github.com/Workwithaditya01/90DaysOfDevOps/blob/1c768dfa4920834bb645edb69f3cfb38628654ec/images/13%20task%2012.png]

---

## Task 3: Create a Volume Group

### Command:

```bash
vgcreate vg_work /dev/nvme1n1 /dev/nvme2n1
```

### Verification:

```bash
vgdisplay
```
#### OR

```bash
lsblk
```

### Screenshot:
![Volume Group][https://github.com/Workwithaditya01/90DaysOfDevOps/blob/1c768dfa4920834bb645edb69f3cfb38628654ec/images/13%20task%2012.png]

---

## Task 4: Create a Logical Volume

### Command:

```bash
lvcreate -L 10G -n lv_work vg_work
```

### Verification:

```bash
lvdisplay
```
#### OR
```bash
lvs
```
---

## Task 5: Format and Mount the Logical Volume

### Format the Volume 

### Command:

```bash
mkfs.ext4 /dev/vg_work/lv_work
```

### Create a Mount Directory

```bash
mkdir /mnt/lv_mount
```

### Mount the Volume 

```bash
mount /dev/vg_work/lv_work /mnt/lv_mount
```

### Verify:

```bash
df-h
```

---

## Task 6: Extend the logical Volume

### Command:

```bash
lvextend -L +200M /dev/vg_work/lv_work
```

### Resize File System:

```bash
resize2fs /dev/vg_work/lv_work
```

### Verify:

```bash
df -h
```

### Screenshot:

![Extend][https://github.com/Workwithaditya01/90DaysOfDevOps/blob/1c768dfa4920834bb645edb69f3cfb38628654ec/images/13%20task%205.png]

---


## Key Learnings
- Learned the architecture of LVM (PV → VG → LV).
- Worked with AWS EBS volumes in a real cloud environment.
- Created and managed Physical Volumes, Volume Groups, and Logical Volumes.
- Formatted and mounted storage using the EXT4 filesystem.
- Extended storage dynamically without data loss.
- Understood how LVM helps in flexible storage management for production systems.

---

