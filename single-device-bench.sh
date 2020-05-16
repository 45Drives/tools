#!/bin/bash
DISK=$1
if [! -b $DISK ];then
    echo "$DISK is not present in the system"
fi
rpm -qa | grep -q fio || yum install fio

echo "LINEAR READ"
fio -ioengine=libaio -direct=1 -invalidate=1 -name=test -bs=4M -iodepth=32 -rw=read -runtime=30 -filename=$1
echo "LINEAR WRITE"
fio -ioengine=libaio -direct=1 -invalidate=1 -name=test -bs=4M -iodepth=32 -rw=write -runtime=30 -filename=$1
echo "Peak parallel random read"
fio -ioengine=libaio -direct=1 -invalidate=1 -name=test -bs=4k -iodepth=128 -rw=randread -runtime=30 -filename=$1
echo "Single-threaded read latency"
fio -ioengine=libaio -sync=1 -direct=1 -invalidate=1 -name=test -bs=4k -iodepth=1 -rw=randread -runtime=30 -filename=$1
echo "Peak parallel random write"
fio -ioengine=libaio -direct=1 -invalidate=1 -name=test -bs=4k -iodepth=128 -rw=randwrite -runtime=30 -filename=$1
echo "Single-threaded random write latency"
fio -ioengine=libaio -sync=1 -direct=1 -invalidate=1 -name=test -bs=4k -iodepth=1 -rw=randwrite -runtime=30 -filename=$1
