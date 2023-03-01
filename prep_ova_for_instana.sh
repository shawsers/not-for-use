echo "remove MariaDB"
yum -y remove mariadb mariadb-server
echo "unmount MariaDB volume"
umount /var/lib/mysql
echo "delete old MariaDB folders"
rm -rf /var/lib/mysql
echo "remove MariaDB volume"
lvchange -an /dev/mapper/turbo-var_lib_mysql
lvremove /dev/mapper/turbo-var_lib_mysql
lvmdiskscan
pvscan
echo "create new volumes for Instana"
lvcreate --name instana_data -L 250G turbo -y
lvcreate --name instana_metrics -L 250G turbo -y
lvcreate --name instana_traces -L 250G turbo -y
mkfs.ext4 /dev/turbo/instana_data
mkfs.ext4 /dev/turbo/instana_metrics
mkfs.ext4 /dev/turbo/instana_traces
mkdir -p /mnt/data /mnt/metrics /mnt/traces
mount /dev/turbo/instana_data /mnt/data
mount /dev/turbo/instana_metrics /mnt/metrics
mount /dev/turbo/instana_traces /mnt/traces
echo "write new volumes to fstab"
echo "/dev/mapper/turbo-instana_data	/mnt/data	ext4	defaults	0 0" >> /etc/fstab
echo "/dev/mapper/turbo-instana_metrics	/mnt/metrics	ext4	defaults	0 0" >> /etc/fstab
echo "/dev/mapper/turbo-instana_traces	/mnt/traces	ext4	defaults	0 0" >> /etc/fstab
echo "install Instana"
cat >/etc/yum.repos.d/Instana-Product.repo <<EOF
[instana-product]
name=Instana-Product
baseurl=https://self-hosted.instana.io/rpm/release/product/rpm/generic/x86_64/Packages
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://self-hosted.instana.io/signing_key.gpg
priority=5
sslverify=1
#proxy=http://x.x.x.x:8080
#proxy_username=
#proxy_password=
EOF
yum clean expire-cache -y
yum makecache -y
yum install -y instana-console
echo "1**check for errors above and correct/rerun as needed**"
echo "2**update /etc/hosts with correct IP for the host**"
echo "3**remove old entry /var/lib_mysql from /etc/fstab"
echo "Instana install prep done, proceed with instana init"
