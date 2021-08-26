#!/bin/bash
#Upgrade pre-check script - August 26, 2021
echo " "
RED=`tput setaf 1`
WHITE=`tput setaf 7`
GREEN=`tput setaf 2`
BLUE=`tput setaf 4`
YELLOW=`tput setaf 3`
NC=`tput sgr0` # No Color

VERBOSE=0

usage () {
   echo "v1.5"
   echo ""
   echo "Usage:"
   echo ""
   echo "   upgrade-precheck.sh [-v] [-h]"
   echo ""
   echo "   Arguments list"
   echo "      -v: turn on verbose mode"
   echo "      -h: this help"
   echo ""
 
   exit 1
}

check_space(){
    echo "${WHITE}****************************"
    echo "${WHITE}Checking for free disk space..."
    #df -h | egrep -v "overlay|shm"
    if [[ $(df | egrep -v "overlay|shm" | grep "/var$" | awk {'print $4'}) > 15728640 ]]; then
        if [[ ${VERBOSE} = 1 ]]; then
            echo "${GREEN}There's enough disk space in /var to proceed with the upgrade"
        fi
        echo "${GREEN}Disk space check PASSED"
    else
        if [[ ${VERBOSE} = 1 ]]; then
            "${RED}/var has less than 15GB free - if needed remove un-used docker images to clear enough space"
            echo "${WHITE}***************************"
            echo " "
            echo "${WHITE}Reclaimable space list below - By deleting un-used docker images${WHITE}"
            sudo docker system df
            echo "${WHITE}To reclaim space from un-used docker images above you need to confirm the previous version of Turbonomic images installed"
            echo "Run the command ${YELLOW}'sudo docker images | grep turbonomic/auth'${WHITE} to find the previous versions"
            echo "Run the command ${YELLOW}'for i in \`sudo docker images | grep 7.22.0 | awk '{print $3}'\`; do sudo docker rmi \$i;done'${WHITE} replacing ${YELLOW}'7.22.0'${YELLOW} with the old previous versions of the docker images installed to be removed to clear up the required disk space"
            echo "${WHITE}***************************"
        fi
        echo "${RED}Disk space checks FAILED"
    fi
    echo "${WHITE}****************************"
    #echo "${GREEN}Please verify disk space above - ${RED}ensure that /var has at least 15GB free - if not please remove un-used docker images to clear enough space"
}

check_internet(){
    echo "${WHITE}****************************"
    echo "${WHITE}Checking endpoints connectivity for ONLINE upgrade ONLY..."
    URL_LIST=( https://index.docker.io https://auth.docker.io https://registry-1.docker.io https://production.cloudflare.docker.com https://raw.githubusercontent.com https://github.com https://download.vmturbo.com/appliance/download/updates/8.2.7/onlineUpgrade.sh https://yum.mariadb.org https://packagecloud.io https://download.postgresql.org https://yum.postgresql.org )
    NOT_REACHABLE_LIST=()
    read -p "${GREEN}Are you using a proxy to connect to the internet on this Turbonomic instance (y/n)? " CONT
    if [[ "${CONT}" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        read -p "${WHITE}What is the proxy name or IP and port you use?....example https://proxy.server.com:8080 " P_NAME_PORT
        echo " "
        echo "${WHITE}Checking endpoints connectivity for ONLINE upgrade ONLY using proxy provided..."
        for URL in "${URL_LIST[@]}"
        do
            if [[ $(curl --proxy $P_NAME_PORT ${URL} --max-time 30 -s -o /dev/null -w "%{http_code}") != @(000|407|502) ]]; then
                if [[ ${VERBOSE} = 1 ]]; then
                    echo "${GREEN}SUCCESSFULLY reached ${URL}"
                fi
            else
                NOT_REACHABLE_LIST+=( $URL )
                if [[ ${VERBOSE} = 1 ]]; then
                    echo "${RED}CANNOT REACH ${URL} - DO NOT PROCEED WITH ONLINE UPGRADE UNTIL THIS IS RESOLVED"
                fi
            fi
        done
    else
        for URL in "${URL_LIST[@]}"
        do
            if [[ $(curl ${URL} --max-time 30 -s -o /dev/null -w "%{http_code}") != @(000|407|502) ]]; then
                if [[ ${VERBOSE} = 1 ]]; then
                    echo "${GREEN}SUCCESSFULLY reached ${URL}"
                fi
            else
                NOT_REACHABLE_LIST+=( ${URL} )
                if [[ ${VERBOSE} = 1 ]]; then
                    echo "${RED}CANNOT REACH ${URL} - DO NOT PROCEED WITH ONLINE UPGRADE UNTIL THIS IS RESOLVED"
                fi
            fi
        done
    fi
    # final check
    if [[ ${#NOT_REACHABLE_LIST[@]} = 0 ]]; then
        echo "${GREEN}Endpoints connectivity checks PASSED"
    else
        echo "${RED}Endpoints connectivity checks FAILED"
        if [[ ${VERBOSE} = 1 ]]; then
            echo "${WHITE}List of failing endpoints:"
            for URL in "${NOT_REACHABLE_LIST[@]}"
            do
                echo "${RED}${URL}"
            done
        fi
    fi
    echo "${WHITE}****************************"
}

check_database(){
    echo "${WHITE}****************************"
    echo "Checking MariaDB status and version..."
    echo "Checking if the MariaDB service is running..."
    MSTATUS=$(systemctl is-active mariadb)
    case ${MSTATUS} in 
        active)
                if [[ ${VERBOSE} = 1 ]]; then
                    echo "${GREEN}MariaDB service is running"
                    echo "${WHITE}Checking MariaDB version"
                fi
                MVERSION=$(systemctl list-units --all -t service --full --no-legend "mariadb.service" | awk {'print $6'})
                # Compare version (if 10.5.9 is the output, that means the version is either equals or above this)
                VERSION_COMPARE=$(echo -e "10.5.9\n${MVERSION}" | sort -V | head -n1)
                if [[ ${VERSION_COMPARE} = "10.5.9" ]]; then
                    echo "${GREEN}MariaDB checks PASSED"
                else                    
                    if [[ ${VERBOSE} = 1 ]]; then
                        echo "${RED}The version of MariaDB is below version 10.5.9 you will also need to upgrade it post Turbonomic upgrade following the steps in the install guide"
                    fi
                    echo "${RED}MariaDB checks FAILED"
                fi
                ;;
        unknown)
                if [[ ${VERBOSE} = 1 ]]; then
                    echo "${WHITE}MariaDB service is not installed, precheck skipped"
                fi
                echo "${GREEN}MariaDB checks PASSED"
                ;;
        *)
                if [[ ${VERBOSE} = 1 ]]; then
                    echo "${RED}MariaDB service is not running....please resolve before upgrading"
                fi
                echo "${RED}MariaDB checks FAILED"
                ;;
    esac
    echo "${WHITE}****************************"
}

check_kubernetes_service(){
    echo "${WHITE}****************************"
    echo "Checking if the Kubernetes service is running..."
    CSTATUS=$(systemctl is-active kubelet)
    if [ "${CSTATUS}" = "active" ]; then
        if [[ ${VERBOSE} = 1 ]]; then
            echo "${GREEN}Kubernetes service is running."
        fi
        echo "${GREEN}Kubernetes service checks PASSED"
    else
        if [[ ${VERBOSE} = 1 ]]; then
            echo "${RED}Kubernetes service is not running. Please resolve before upgrading"
        fi
        echo "${RED}Kubernetes service checks FAILED"
    fi
    echo "${WHITE}****************************"
}

check_kubernetes_certs(){
    echo "${WHITE}****************************"
    echo "Checking for expired Kubernetes certificates..."
    echo "Checking all certs now..."
    kubeVersion=$(/usr/local/bin/kubectl version | awk '{print $4}' | head -1 | awk -F: '{print $2}' | sed 's/"//g' | sed 's/,//g')
    if [[ $kubeVersion -ge 20 ]]; then
        sudo /usr/local/bin/kubeadm certs check-expiration
    elif [[ $kubeVersion -ge 15 ]]; then
        sudo /usr/local/bin/kubeadm alpha certs check-expiration
    else
        sudo find /etc/kubernetes/pki/ -type f -name "*.crt" -print|egrep -v 'ca.crt$'|xargs -L 1 -t  -i bash -c 'openssl x509  -noout -text -in {}|grep After'
    fi
    echo "${GREEN}Please validate the EXPIRES dates above, ${RED}if the EXPIRES dates listed above is before current date please run the script kubeNodeCertUpdate.sh in /opt/local/bin to renew the expired certs before upgrading"
    echo "${WHITE}****************************"
}

# Main script
# Check for arguments
while getopts "vh" ARGUMENTS
do
   case ${ARGUMENTS} in
      v)
         echo "${WHITE}Verbose Mode ON"
         VERBOSE=1
         ;;
      h)
         usage
         ;;
   esac
done
echo "${GREEN}Starting Upgrade Pre-check..."
echo " "
check_space
echo " "
check_internet
echo " "
check_database
echo " "
check_kubernetes_service
echo " "
check_kubernetes_certs

echo "${WHITE}*****************************"
echo " "
echo "Checking if root password is expired or set to expire..."
echo "${GREEN}root account details below${WHITE}"
sudo chage -l root
echo "${GREEN}Please validate the expiry dates above, ${RED}if expired or not set please set/reset the password before proceeding"
echo "${WHITE}*****************************"
echo " "
echo "${GREEN}Checking if NTP is enabled for timesync...${WHITE}"
timedatectl | grep "NTP enabled"
echo "${GREEN}Checking if NTP is synchronized for timesync...${WHITE}"
timedatectl | grep "NTP sync"
echo "${GREEN}Checking if Chronyd is running for NTP timesync...${WHITE}"
sudo systemctl status chronyd | grep Active
echo "${GREEN}Checking list of NTP servers being used for timesync (if enabled and running)...${WHITE}"
cat /etc/chrony.conf | grep server
echo "${GREEN}Current date, time and timezone configured (default is UTC time)...${WHITE}"
date
echo "${GREEN}Please validate NTP, TIME and DATE configuration above if it is required, ${RED}if not enabled or correct and it is required please resolve by reviewing the Install Guide for steps to Sync Time"
echo "${WHITE}*****************************"
echo " "
echo "${GREEN}Checking for any Turbonomic pods not ready and running...${WHITE}"
if [ -f "/opt/turbonomic/kubernetes/yaml/persistent-volumes/local-storage-pv.yaml" ]; then
    gluster_enabled=false
    kubectl get pod -n turbonomic | grep -Pv '\s+([1-9]+)\/\1\s+' | grep -v "NAME"
else
    gluster_enabled=true
    kubectl get pod -n turbonomic | grep -Pv '\s+([1-9]+)\/\1\s+' | grep -v "NAME"
    kubectl get pod -n default | grep -Pv '\s+([1-9]+)\/\1\s+' | grep -v "NAME"
fi
echo "${GREEN}Please resolve issues with the pods listed above (if any), ${RED}if you cannot resolve on your own **please contact support**"
echo "${WHITE}*****************************"
echo " "
echo "${GREEN}Please take time to review and resolve any issues above before proceeding with the upgrade, ${RED}if you cannot resolve **please contact support**"
echo " "
echo "${GREEN}End of Upgrade Pre-Check${WHITE}"
