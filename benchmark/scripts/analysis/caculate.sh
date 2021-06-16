#!/bin/bash

for folder in "$@"
do
    # Fuzzer Dir
    echo $folder
    
    abs_folder=$(readlink -f $folder)
    echo $abs_folder

    fuzzer_stats="${abs_folder}/fuzzer_stats"
    echo $fuzzer_stats
    total_queues=$(grep paths_total $fuzzer_stats | awk -F" " '{print $NF}')
    exec_dones=$(grep execs_done $fuzzer_stats | awk -F" " '{print $NF}')

    ipsm_file="${abs_folder}/ipsm.dot"
    unique_state=$(/usr/bin/gc -n -e $ipsm_file | awk -F" " '{print $1}')
    
    echo "Finish - $total_queues/$exec_dones - $unique_state"
    echo " "
done

