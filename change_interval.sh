##Start of script
echo "Starting script"
##First you need to find the probe id that you want to change the timeout for
# 1 - Access the regular API – https://turbo-ip/apidoc
# 2 - Scroll to the Targets section
# 3 - Expand GET Targets, click Try it out (top right of section)
# 4 - Select ONPREM and Execute.
# 5 - Scroll through the results and note the UUIDs for the vCenter category: “hypervisor” targets.
##Now enter IP of your Topology Processor internal IP below and the UUID's of the targets above
##This will query to see what the existing discovery internal is
##Get IP of Topology Processor service
TPIP=$(kubectl get services | grep topo | awk '{print $3}')
##Get export of targets and export to file
echo "Get list of targets via API"
curl -X GET "http://$TPIP:8080/target" -H "accept: application/json;charset=UTF-8" >> /tmp/export.json
echo ""
echo "Parse output of targets"
cat /tmp/export.json | grep targetId -A 1

##echo "Checking discovery intervals"
#curl -X POST "http://$TPIP:8080/ScheduleService/getDiscoverySchedule" -H "accept: application/json;charset=UTF-8" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"targetId\": 74054410720384}"
#curl -X POST "http://$TPIP:8080/ScheduleService/getDiscoverySchedule" -H "accept: application/json;charset=UTF-8" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"targetId\": 74054411682144}"

##This will change the discovery interval as needed - change values in mins and seconds as you like
#echo "Updating discovery intervals"
#curl -X POST "http://10.233.6.57:8080/ScheduleService/setDiscoverySchedule" -H "accept: application/json;charset=UTF-8" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"targetId\": 74054410720384, \"fullIntervalMinutes\": 10, \"incrementalIntervalSeconds\": 30}"
#curl -X POST "http://10.233.6.57:8080/ScheduleService/setDiscoverySchedule" -H "accept: application/json;charset=UTF-8" -H "Content-Type: application/json;charset=UTF-8" -d "{ \"targetId\": 74054411682144, \"fullIntervalMinutes\": 10, \"incrementalIntervalSeconds\": 30}"

echo "End of script"
##End of script
