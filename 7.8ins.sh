#!/usr/bin/env bash

#start
cd /
device=$(lsblk -ro TYPE,NAME|awk '($1=="disk") {print $2}')
gate=$(ip route get 1.1.1.1|head -n 1|cut -f 3 -d\ )
ipa=$(ip route get 1.1.1.1|head -n 1|cut -f 7 -d\ )
mask=24
mirror='http://templates.repo.onapp.com/Linux/centos-7.8-x64-1.0-xen.kvm.kvm_virtio.tar.gz'

[ -d /ncroot ]||mkdir /ncroot

if command -v wget
then true
else echo '没有wget命令';exit
fi

wget -O /ncroot/tmp.tar.gz $mirror;tar xzf /ncroot/tmp.tar.gz -C /ncroot

cp -a /etc/fstab /ncroot/etc/fstab

cat <<EOF >/ncroot/etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=static
PREFIX=8
IPADDR=$ipa
GATEWAY=$gate
EOF

sleep 1
#del
find / \( ! -path '/dev/*' -and ! -path '/proc/*' -and ! -path '/sys/*' -and ! -path '/ncroot/*' \) -delete 2>/dev/null || true
#
exechroot() {
/ncroot/lib64/ld-linux-x86-64.so.2 --library-path /ncroot/lib64 "$@"
}

exechroot /ncroot/bin/cp -a /ncroot/* /
ldconfig
#grub
for i in $device
do
    grub2-install /dev/$i
      grub2-mkconfig -o /boot/grub2/grub.cfg
done
#
#passwd
echo root:cnddy159|chpasswd
#
echo nameserver\ 8.8.8.8 >/etc/resolv.conf
#end
rm -rf /ncroot /tmp.tar.gz
echo "安装完成"
echo -e "\n\n重启命令 reboot -f;root密码cnddy159\n\n"
