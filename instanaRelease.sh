#!/bin/bash
MAJOR=1
#service=${PWD##*/} #gets the current directory name for the service name
service=$VMT_CURRENT_NAME
#if [[ $1 == '' ]]; then echo "Must pass a patch number"; exit 1; fi
#if [[ $2 == '' ]]; then ts=$(date +%s); else ts=$2; fi

if [ "$service" == '' ]; then
	echo "Could not retrieve Service name from the env variable VMT_CURRENT_NAME"
else

ts=$(date +%s)
oc login https://api.labs.ihost.com:6443 -u ocadmin -p ibmocp48
VER=$(oc -n robot-shop get deploy $service -o=jsonpath='{.status.observedGeneration}')
if [ $VER == '' ]; then
	RELEASE='latest'
else
  RELEASE="$MAJOR.0.$VER"
fi
  
  echo "Publishing release to Instana"
curl -k -X POST "https://instanaserv.labs.ihost.com/api/releases"  \
  --header "Authorization: apiToken 1Ut0ntLaRlC0MiMq5yHStw" \
  --header "Content-Type: application/json" \
  --data "{
	\"name\": \"$service-$RELEASE\",
	\"start\": ${ts}000,
	\"services\": [
      {
        \"name\": \"${service}\",
        \"scopedTo\": {
          \"applications\": [
            {
              \"name\": \"Robot Shop\"
            }
          ]
        }
      }
    ]
}"

fi
