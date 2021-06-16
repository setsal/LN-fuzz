#!/bin/bash

folder=$1   #fuzzer result folder
pno=$2      #port number
step=$3     #step to skip running gcovr and outputting data to covfile
            #e.g., step=5 means we run gcovr after every 5 test cases
fmode=$4    #file mode -- structured or not
      

#output the header of the coverage file which is in the CSV format
#Time: timestamp, l_per/b_per and l_abs/b_abs: line/branch coverage in percentage and absolutate number

#files stored in replayable-* folders are structured
#in such a way that messages are separated
if [ $fmode -eq "1" ]; then
  testdir="replayable-queue"
  replayer="/home/ubuntu/lnfuzz/src/aflnet-showmap"
else
  testdir="queue"
  replayer="/home/ubuntu/lnfuzz/src/aflnet-showmap-nwe"
fi

#process initial seed corpus first
for f in $(echo $folder/$testdir/*.raw); do 

  $replayer $f SIP $pno 1 > /dev/null 2>&1 & ./run_pjsip > /dev/null 2>&1 &
  timeout -k 0 -s SIGTERM 3s ./kamailio-gcov/src/kamailio -f ./kamailio-basic.cfg -L ./kamailio-gcov/src/modules -Y ./kamailio-gcov/runtime_dir/ -n 1 -D -E > /dev/null 2>&1
  
  wait
  
done

#process fuzzer-generated testcases
count=0
for f in $(echo $folder/$testdir/id*); do 
  time=$(stat -c %Y $f)

  $replayer $f SIP $pno 1 > /dev/null 2>&1 & ./run_pjsip > /dev/null 2>&1 &
  timeout -k 0 -s SIGTERM 3s ./kamailio-gcov/src/kamailio -f ./kamailio-basic.cfg -L ./kamailio-gcov/src/modules -Y ./kamailio-gcov/runtime_dir/ -n 1 -D -E > /dev/null 2>&1

  wait
  count=$(expr $count + 1)
  rem=$(expr $count % $step)
  if [ "$rem" != "0" ]; then continue; fi
  
done

