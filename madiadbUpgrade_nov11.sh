# mariadbUpgrade.sh

echo " "
RED=`tput setaf 1`
WHITE=`tput setaf 7`
GREEN=`tput setaf 2`
BLUE=`tput setaf 4`
YELLOW=`tput setaf 3`
NC=`tput sgr0` # No Color

#reset terminal on exit not to mess with colors
trap 'tput sgr0' EXIT

#check if offline iso is mounted or not
ISOCHECK=$(ls /mnt/iso)
read -p "${GREEN}Are you performing OFFLINE upgrade (y/n)? " OFL
echo " "
if [[ "${OFL}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  if [ -z "$ISOCHECK" ]
  then
    echo "${RED}Upgrade ISO NOT mounted, script exiting now, please mount upgrade ISO and try again..."
    exit
  else
    echo "${WHITE}Upgrade ISO mounted, proceeding..."
  fi
else
  echo "${WHITE}ONLINE upgrade proceeding now..."
fi
