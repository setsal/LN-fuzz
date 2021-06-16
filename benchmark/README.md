# Fuzz bench

Stateful fuzz bench with script modified and added

# Usage

整體架構與基本使用方法請參考 profuzzbench 說明

但是執行進入點改為使用 `scripts/execution/profuzzbench_exec_common_showmap.sh`

Bench script 改為採用 `scripts/analysis/bench_edge_store.py`

BTW 改了很多東西 小心使用

# Origin by

[ProFuzzBench](https://github.com/profuzzbench/profuzzbench)
