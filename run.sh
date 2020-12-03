#!/bin/bash

cd DBx1000

SCRIPT=/home/ubuntu/cicada-exp-sigmod2017/cicada-engine/script/setup.sh

$SCRIPT 24576 24576


for w in 1 4
do
  sed -i "s/^#define PART_CNT .*$/#define PART_CNT $w/g" config.h
  sed -i "s/^#define NUM_WH .*$/#define NUM_WH $w/g" config.h
  OUTFILE="c-${w}w-results.txt"
  printf "# Threads" >> $OUTFILE
  for k in {1..5}
  do
    printf ",Cicada (W$w) [T$k]" >> $OUTFILE
  done
  printf "\n" >> $OUTFILE
  for i in 1 2 4 12 23 24 31 32 36 47 48
  do
    printf "$i" >> $OUTFILE
    sed -i "s/^#define THREAD_CNT .*$/#define THREAD_CNT $i/g" config.h
    make clean > /dev/null 2>&1
    make rundb -j40 > /dev/null 2>&1
    for k in {1..5}
    do
      cicada=$(sudo ./rundb 2>/dev/null | grep '^committed:' | grep -oE '[0-9.]+ M/sec' | grep -oE '[0-9.]+')
      #success=$(sudo ./rundb 2>/dev/null | grep '^committed:' | grep -oE '[0-9.]+% attempts' | grep -oE '[0-9.]+')
      #cicada=$(echo "100-$success" | bc)
      printf ",$cicada" >> $OUTFILE
      sleep 1
    done
    printf "\n" >> $OUTFILE
  done
done

$SCRIPT 0 0
