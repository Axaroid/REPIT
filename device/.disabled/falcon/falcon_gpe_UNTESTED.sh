#####################################################
# Lanchon REPIT - Device Handler                    #
# Copyright 2016, Lanchon                           #
#####################################################

#####################################################
# Lanchon REPIT is free software licensed under     #
# the GNU General Public License (GPL) version 3    #
# and any later version.                            #
#####################################################

### falcon_gpe (GPE version)

# Disk /dev/block/mmcblk0: 30777344 sectors, 14.7 GiB
# Logical sector size: 512 bytes
# Disk identifier (GUID): 98101B32-BBE2-4BF2-A06E-2BB33D000C20
# Partition table holds up to 37 entries
# First usable sector is 34, last usable sector is 30777310
# Total free space is 72203 sectors (35.3 MiB)
# 
# Number  Start (sector)    End (sector)  Size       Code  Name
#    1             256          131327   64.0 MiB    0700  modem
#    2          131328          132351   512.0 KiB   FFFF  sbl1
#    3          132352          132415   32.0 KiB    FFFF  DDR
#    4          132608          133631   512.0 KiB   FFFF  aboot
#    5          135608          136007   200.0 KiB   FFFF  rpm
#    6          136608          137407   400.0 KiB   FFFF  tz
#    7          137608          137671   32.0 KiB    FFFF  sdi
#    8          137672          138695   512.0 KiB   FFFF  utags
#    9          138696          142791   2.0 MiB     FFFF  logs
#   10          142792          147455   2.3 MiB     0700  metadata
#   11          147456          148479   512.0 KiB   FFFF  abootBackup
#   12          150456          150855   200.0 KiB   FFFF  rpmBackup
#   13          151456          152255   400.0 KiB   FFFF  tzBackup
#   14          152456          152519   32.0 KiB    0700  sdiBackup
#   15          152520          153543   512.0 KiB   FFFF  utagsBackup
#   16          153544          155647   1.0 MiB     0700  padB
#   17          155648          158719   1.5 MiB     FFFF  modemst1
#   18          158720          161791   1.5 MiB     FFFF  modemst2
#   19          161792          162815   512.0 KiB   FFFF  hob
#   20          162816          162831   8.0 KiB     FFFF  dhob
#   21          163072          166143   1.5 MiB     FFFF  fsg
#   22          166144          166145   1024 bytes  FFFF  fsc
#   23          166146          166161   8.0 KiB     FFFF  ssd
#   24          166162          168209   1024.0 KiB  FFFF  sp
#   25          168210          168465   128.0 KiB   FFFF  cid
#   26          168466          174609   3.0 MiB     FFFF  pds
#   27          174610          182801   4.0 MiB     FFFF  logo
#   28          182802          190993   4.0 MiB     FFFF  clogo
#   29          191232          207615   8.0 MiB     0700  persist
#   30          207616          208639   512.0 KiB   FFFF  misc
#   31          208640          229119   10.0 MiB    FFFF  boot
#   32          229120          249599   10.0 MiB    FFFF  recovery
#   33          249600          262143   6.1 MiB     0700  padC
#   34          262144         1409023   560.0 MiB   0700  cache
#   35         1409024         3129343   840.0 MiB   0700  system
#   36         3129344         3145727   8.0 MiB     FFFF  kpan
#   37         3145728        30711551   13.1 GiB    0700  userdata

device_makeFlashizeEnv="env/arm.zip"

#device_makeFilenameConfig="cache=32M+wipe-system=same-data=max"
#device_makeFilenameConfig="cache=32M+wipe-system=976M-data=max"

device_makeFilenameConfig="cache=424M+wipe-system=976M-data=same"

device_checkDevice() {

    checkTool getprop

    case ":$(getprop ro.product.device):$(getprop ro.build.product):" in
        *:falcon:*) ;;
        *)
            fatal "this package is for '$deviceName' devices; this device is '$(getprop ro.product.device)'"
            ;;
    esac

}

device_init() {

    device_checkDevice

    # the block device on which REPIT will operate (only one device is supported):

    #sdev=/sys/devices/msm_sdcc.1/mmc_host/mmc0/mmc0:0001/block/mmcblk0
    sdev=/sys/block/mmcblk0
    spar=$sdev/mmcblk0p

    ddev=/dev/block/mmcblk0
    dpar=/dev/block/mmcblk0p

    sectorSize=512      # in bytes

    # a grep pattern matching the partitions that must be unmounted before REPIT can start:
    #unmountPattern="${dpar}[0-9]\+"
    unmountPattern="/dev/block/mmcblk[^ ]*"

}

device_initPartitions() {

    # the set of partitions that can be modified by REPIT:
    #     <gpt-number>  <gpt-name>  <friendly-name> <conf-defaults>     <crypto-footer>
    initPartition   34  cache       cache           "same keep ext4"    0
    initPartition   35  system      system          "same keep ext4"    0
    initPartition   36  kpan        kpan            "same keep raw"     0
    initPartition   37  userdata    data            "same keep ext4"    0

    # the set of modifiable partitions that can be configured by the user (overriding <conf-defaults>):
    configurablePartitions="34 35 37"

}

device_setup() {

    # the number of partitions that the device must have:
    partitionCount=37

    # the set of defined heaps:
    allHeaps="main"

    # the partition data move chunk size (must fit in memory):
    moveDataChunkSize=$(( 256 * MiB ))

    # only call this if you will later use $deviceHeapStart or $deviceHeapEnd:
    detectBlockDeviceHeapRange

    # the size of partitions configured with the 'min' keyword:
    #heapMinSize=$(( 8 * MiB ))
    
    # the partition alignment:
    heapAlignment=$(( 4 * MiB ))

}

device_setupHeap_main() {

    # the set of contiguous partitions that form this heap, in order of ascending partition start address:
    heapPartitions="$(seq 34 37)"

    # the disk area (as a sector range) to use for the heap partitions:
    heapStart=$(parOldEnd 33)       # one past the end of a specific partition
    heapEnd=$deviceHeapEnd          # one past the last usable sector of the device

}
