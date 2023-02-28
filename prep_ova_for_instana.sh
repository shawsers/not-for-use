echo "change root password"
sudo su -
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
echo "create new volume for Instana"
lvcreate --name instana_data -l 100%FREE turbo
mkfs.ext4 /dev/turbo/instana_data
mkdir /mnt
mount /dev/turbo/instana_data /mnt
mkdir -p /mnt/data /mnt/metrics /mnt/traces
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
echo "**check for errors above and correct/rerun as needed**"
echo "**update /etc/hosts with correct IP for the host**"
echo "Instana install prep done, proceed with instana init"
