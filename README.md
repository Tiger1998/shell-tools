# shell-tools
记录一些在学习shell过程中，顺带编写的小工具



1.autoAddDisk.sh
> 用于阿里云ecs服务器挂载硬盘使用




=======================================================================

#问题列表:

如果运行时提示：-bash: xxx: /bin/bash^M: bad interpreter: No such file or directory
方法1:直接使用dos2unix命令修改: dos2unix xxx.sh
方法2:VI打开sh文件后，:set ff=unix
