#Turbo Broadcast in k8s
#make sure to run "chmod 777 broadcast.sh" before running
#run the file ./broadcast.sh
echo "###########################"
echo "# RUNNING TURBO BROADCAST #"
echo "###########################"
rs=$(kubectl get pod -n turbonomic | grep rsyslog | awk '{print $1}')
tp=$(kubectl get services -n turbonomic | grep topology-processor | grep 8080 | awk '{print $3}')
kubectl exec -it $rs -n turbonomic -- curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' http://$tp:8080/topology/send
