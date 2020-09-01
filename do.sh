#########################################################################
# File Name: do.sh
# Author: Sues
# mail: sumory.kaka@foxmail.com
# Created Time: Tue 01 Sep 2020 12:15:58 PM CST
# Version : 1.0
#########################################################################
#!/bin/bash

function checkOutSimpleCode {

    PWD=`pwd`
    DIR_NAME=${PWD##*/}
    #echo DIR_NAME:${DIR_NAME}
    SIMPLE_SOURCE_DIR=../${DIR_NAME}_simple
    [ -d ${SIMPLE_SOURCE_DIR} ] && rm ${SIMPLE_SOURCE_DIR} -rf
    mkdir ${SIMPLE_SOURCE_DIR}

    find . -name "*.o" | while read -r FILE_READ ; do
        # echo $FILE_READ

        # .o 文件
        cp --parents ${FILE_READ} ${SIMPLE_SOURCE_DIR}

        # .s .S .c 文件
        [ -e ${FILE_READ%.*}.c  ] && FILE=${FILE_READ%.*}.c
        [ -e ${FILE_READ%.*}.s ] && FILE=${FILE_READ%.*}.s
        [ -e ${FILE_READ%.*}.S  ] && FILE=${FILE_READ%.*}.S
        cp --parents ${FILE} ${SIMPLE_SOURCE_DIR}

        # .xxx.o.cmd 文件
        OBJ_PATH=${FILE_READ%/*}
        OBJ_FILE=${FILE_READ##*/}
        cp --parents ${OBJ_PATH}/.${OBJ_FILE}.cmd ${SIMPLE_SOURCE_DIR}
    done

    find . -name "*.ko" | while read -r FILE_READ ; do
        # echo $FILE_READ

        # .ko 文件
        cp --parents ${FILE_READ} ${SIMPLE_SOURCE_DIR}

        # .xxx.ko.cmd 文件
        OBJ_PATH=${FILE_READ%/*}
        OBJ_FILE=${FILE_READ##*/}
        cp --parents ${OBJ_PATH}/.${OBJ_FILE}.cmd ${SIMPLE_SOURCE_DIR}
    done


    find . -name modules.builtin -exec cp {} --parents ${SIMPLE_SOURCE_DIR} \;
    find . -name modules.order   -exec cp {} --parents ${SIMPLE_SOURCE_DIR} \;

    # Makefile  Kbuild  Kconfig
    find . -name Kconfig -or -name Kbuild  -or -name Makefile -type f | while read -r FILE_READ ; do
        FILE_PATH=${FILE_READ%/*}
        [ -d ${SIMPLE_SOURCE_DIR}/${FILE_PATH} ] && cp ${FILE_READ} ${SIMPLE_SOURCE_DIR}/${FILE_PATH}
    done



    # 其他重要文件
    FILE_ISSUE=" vmlinux System.map "
    FILE_ISSUE+=" .config "
    FILE_ISSUE+=" .missing-syscalls.d .tmp_System.map .tmp_kallsyms1.S .tmp_kallsyms2.S .tmp_vmlinux1 .tmp_vmlinux2 .version Module.symvers arch/arm/kernel/asm-offsets.s arch/arm/lib/lib.a include/linux/version.h kernel/bounds.s lib/lib.a usr/.initramfs_data.cpio.d "

    for file in ${FILE_ISSUE};do
        cp ${file} ${SIMPLE_SOURCE_DIR} --parents
    done

    # 其他重要目录

    DIR_ISSUE="include "
    DIR_ISSUE+="include/config "
    DIR_ISSUE+="include/generated "
    DIR_ISSUE+=".tmp_versions "
    DIR_ISSUE+="arch/arm/include "

    for dir in ${DIR_ISSUE};do
        cp ${dir} ${SIMPLE_SOURCE_DIR} --parents -r
    done

    echo simple code is in ${SIMPLE_SOURCE_DIR}

}

function Main {

    [ $# -ne 1 ] && echo usage : ./do.sh xxx && exit -1

    CPU_NM=`cat /proc/cpuinfo  |grep processor | wc -l`
    let cpu_power=${CPU_NM}*3/5
    [ ${cpu_power} -lt 1 ] && let cpu_power=1


    if [ $1 == config ];then
        make ARCH=arm CROSS_COMPILE=arm-linux- ok6410_defconfig
    elif [ $1 == build ];then
        make ARCH=arm CROSS_COMPILE=arm-linux- -j${cpu_power}
    elif [ $1 == clean ];then
        make mrproper
    elif [ $1 == simple ];then
        [ ! -e init/main.o ] && echo please build kernel first && exit -2
        checkOutSimpleCode
    else
        echo ${1} is not supported
    fi

}

Main $*
