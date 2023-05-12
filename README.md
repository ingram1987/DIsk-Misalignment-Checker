# DIsk-Misalignment-Checker
Checks for disks that are misaligned, which can cause problems with backup, restore, and export jobs with a variety of backup software.

This script is inspired by this article from Quest (RapidRecovery): https://support.quest.com/kb/4035614/volume-offset-or-disk-misalignment-errors
```
Identify disk misalignment
1) On the server which will not protect a volume run the command msinfo32 from a Command Prompt
2) Within the MSINFO32 Browse to Components | Storage | Disks
3) For the disk containing the volume that will not snapshot - Note the overall disk size - (299,966,300,160 bytes in the example screenshot above)
4) Add the Partition Starting offset of the first partition (1,048,576) and the individual partition sizes of the partitions on the disk (104,857,600 and 299,958,462,464 bytes)
5) Compare the figure from step 3 with the figure from step 4
6) In this example: 1,048,576 + 104,857,600 + 299,958,462,464 = 300,064,368,640 - which is larger than the actual disk total size of 299,966,300,160 bytes.  This indicates misalignment on the disk
7) Subtract the total disk size 299,966,300,160 from the combined partition sizes (300,064,368,640) = 98068480 bytes.
8) Convert 98068480 bytes to MB gives a figure of 93.52 MB

Shrink Identified Misaligned volumes
1) Open Diskmgmt.msc
2) Right click the volume that is failing in protection and choose Shrink Volume
3) Shrink the volume by the value appropriately larger than from the previous step 8 (eg. 100MB)
4) Following completion of the disk shrink test the snapshot again
```
