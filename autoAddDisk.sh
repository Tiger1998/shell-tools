#!/bin/bash
# 本功能仅用来对新附加硬盘进行自动识别、自动分区、自动挂载并添加开机自动挂载
#
#设置环境变量
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#设置语言环境为英文
LANG=en_US.UTF-8
#设置目标挂载目录
MyDir="/MyData"

#=======================函数集===========================#
#1.获取当前硬盘
function getDisk(){
	#获取当前有效硬盘(以下二种方法均通过排序获取最新的一块硬盘)
	#FindResult=`fdisk -l | grep -o "^Disk /dev/[sh]d[a-z]" | awk -F ' ' '{print $2}' |sort -r`
	#FindResult=`fdisk -l |grep 'Disk' |awk -F ':' '{print $1}'|awk '/dev/&&!/mapper/{print $2}' |sort -r`
	FindResult=`cat /proc/partitions|grep -v name|grep -v ram|awk '{print "/dev/"$4}'|grep -v '^$'|grep -v '[0-9]$'|grep -v 'vda'|grep -v 'xvda'|grep -v 'sda'|grep -e 'vd' -e 'sd' -e 'xvd'`
	
	#把获取的硬盘结果变成数组
	MyDiskArray=(${FindResult})
	#获取当前硬盘
	echo ${MyDiskArray[0]}
}

#2.格式化分区
function Partition(){
disk=$1
dd if=/dev/zero of=${disk} bs=1024 count=1024
echo "n
p
1
2048

p
w"| fdisk ${disk}
sleep 3
}
#=======================主程 ===========================#

CurrentDisk=$(getDisk)

echo "$CurrentDisk is to init,Are you sure?"
read  -p "Continue? Y|n or N|n:  " CHOICE
if [ $CHOICE == 'N' -o $CHOICE == 'n' ];then
    echo "You chose no"
    echo "The shell is quiting"
    exit 0
elif [ $CHOICE == 'Y' -o $CHOICE == 'y' ];then
    echo "You chose yes,init will begin"
    echo "initing....please wait"
	
	#判断是否已挂载
	isM=`df -P|grep ${CurrentDisk}1`
	if [ "$isM" != "" ];then
		echo "${CurrentDisk}1 has been mounted."
		echo "you can use it."
		exit 1;
	fi
	
	#判断是否已经分区
	isFenqu=`fdisk -l |grep ${CurrentDisk}1`
	if [ "$isFenqu" != "" ];then
		echo "${CurrentDisk}1 has been mkfs."
	else
		#开始分区操作
		echo "mkfs initing...."
		Partition ${CurrentDisk}
		#格式化分区
		mkfs=`mkfs.ext4 ${CurrentDisk}1 `
	fi	

	#挂载硬盘
	mkdir -p ${MyDir}
	sleep 1
	
	echo "mount disk...."
	mount ${CurrentDisk}1 ${MyDir}
	sleep 1
	
	#再次判断是否已挂载成功
	echo "checking mounted...."
	isM=`df -P|grep ${CurrentDisk}1`
	if [ "$isM" != "" ];then
		echo "${CurrentDisk}1 has been mounted."
		#开始添加到自启动
		addAuto=`echo "${CurrentDisk}1 ${MyDir} ext4 defaults 1 2" >> /etc/fstab`
	else
		echo "sorry,mount failed....."
	fi	
	
fi