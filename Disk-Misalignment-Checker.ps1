###################################################
###########Disk Misalignment Checker###############
#############Created by ingram1987#################
############Created on May 11, 2023################
###################################################

# Script inspired by this article: https://support.quest.com/kb/4035614/volume-offset-or-disk-misalignment-errors

#Get all disks on system
$disks = Get-WmiObject -Class Win32_DiskDrive
$misaligned = $false

#This will be the final result, letting you know if any disk is misaligned
$DiskIsMisaligned = $false

#Iterate through each disk, get stats about disk/partitons, store them in $partitionData
$partitionData = foreach ($disk in $disks) {
    $partitions = Get-WmiObject -Class Win32_DiskPartition -Filter "DiskIndex=$($disk.Index)"
    foreach ($partition in $partitions) {
        $diskSize = $disk.Size
        $partitionSize = $partition.Size
        $partitionOffset = $partition.StartingOffset
        $deviceID = $disk.DeviceID
        $partitionNumber = $partition.Index
        [pscustomobject]@{
            DeviceID = $deviceID
            DiskSize = $diskSize
            PartitionNumber = $partitionNumber
            PartitionSize = $partitionSize
            PartitionOffset = $partitionOffset
        }
    }
}

#Iterate through each partition of each disk, list stored stats
Write-Host "Disk/Partition Info:"
foreach ($partition in $partitionData) {
    Write-Host "Device ID: $($partition.DeviceID), Disk Size (bytes): $($partition.DiskSize), Partition $($partition.PartitionNumber) Size (bytes): $($partition.PartitionSize), Partition $($partition.PartitionNumber) Offset (bytes): $($partition.PartitionOffset)"
}

Write-Host ""
Write-Host "Disk Info w/Misalignment Status:"

#Sort data
$partitionDataGrouped = $partitionData | Group-Object -Property DeviceID
$partitionDataGrouped = $partitionDataGrouped | Sort-Object Name

#Calculate misalignment
foreach ($group in $partitionDataGrouped) {
    $deviceID = $group.Name
    $partitionSum = 0
    foreach ($partition in $group.Group) {
        $partitionSum += $partition.PartitionSize
    }
    $partitionSum += $group.Group[0].PartitionOffset
    $difference = $partitionSum - $group.Group[0].DiskSize
    $misaligned = $difference -gt 0
    if ($misaligned) {
        $DiskIsMisaligned = $true
    }
    #List stats about each partition on each disk, and if that individual partition is misaligned
    Write-Host "Device ID: $deviceID, Disk Size (bytes): $($group.Group[0].DiskSize), Total Partition Size (bytes): $partitionSum, Difference (bytes): $difference, Misaligned: $misaligned"
}

#Final result. If any partition is misaligned, this will be True
Write-Host ""
Write-Host "Final Result. True if any Disk/Partition is misaligned:"
Write-Host "DiskIsMisaligned: $DiskIsMisaligned"
