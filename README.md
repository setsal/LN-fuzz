# LN-fuzz: State Sequence Network Protocol Fuzzer 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](https://github.com/setsal/LN-fuzz/blob/main/LICENSE)

# Installation

## Prerequisites

```bash
# ln-fuzz
sudo apt-get install clang
sudo apt-get install graphviz-dev

# benchmark script
pip install pandas matplotlib click numpy
```

## Compile

```bash
# First, clone this repository to a folder named lnfuzz
git clone <links to the repository> lnfuzz

# Then move to the source code folder
cd lnfuzz/src
make clean all
cd llvm_mode
make

# Move to parent folder
cd ../..
export LNFUZZSRC=$(pwd)/src
export WORKDIR=$(pwd)
```

## Setup PATH environment variables

```bash
cd lnfuzz
export LNFUZZSRC=$(pwd)/src
export WORKDIR=$(pwd)
export PATH=$LNFUZZSRC:$PATH
export AFL_PATH=$LNFUZZSRC
```


## Others

建議直接用 benchmark 的 folder 進行 docker script 測試


# Example Usage

基本參數如 AFLNet，新增 `-u`、`-b` 做上限的 alpha、beta 值自訂義調整

Example Command
```bash
ln-fuzz -d -i in -o out -N <server info> -x <dictionary file> -u <alpha> -b <beta> -P <protocol> -D 10000 -q 3 -s 3 -E -K -R <executable binary and its arguments (e.g., port number)>
```

Live555 RTSP Sample command: 
```bash
ln-fuzz -d -i $LNFUZZSRC/tutorials/live555/in-rtsp -o out-live555 -N tcp://127.0.0.1/8554 -x $LNFUZZSRC/tutorials/live555/rtsp.dict -u 5000 -b 10 -P RTSP -D 10000 -q 3 -s 3 -E -K -R ./testOnDemandRTSPServer 8554
```


# Bench 

詳見 `benchmark` 資料夾 README

# Caution & TODO

由於為基於 AFL/AFLNET 做修改，雖然已經盡量移除相關 coverage 資訊的參考

但仍有部分冗餘的程式碼可以做精簡化

如果要面相韌體的測試，仍須搭配 harness 相關的配合

此外，在未做特別修改的狀況下，AFL 原本的 `dumb mode`、`no forkserver mode`、`qemu mode` 皆無法使用 (雖然本來也就不是目標要求)



最後建議是可以參考相同方法，改為 python 用支援較為良好的 Boofuzz 實作相同算法，應該也會讓整個 code 稍微更有系統和容易整合一點

BTW 改了很多東西 小心使用


# Credits
- Mutation strategy & State Sequence Network Module 
    - [google/AFL] (https://github.com/google/AFL)
    - [aflnet/aflnet] (https://github.com/aflnet/aflnet)
