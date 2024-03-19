echo "Starting script to deploy Turbo Secure Client (TSC) via OperatorHub in Red Hat OpenShift"
echo ""
echo "Getting Certified TSC from OperatorHub"
kto=$(oc get packagemanifests | grep t8c-tsc | grep Certified | awk '{print $1}')
echo $kto
#only get "t8c-tsc-client-certified"
echo ""
echo "Getting latest version of Certified TSC from OperatorHub to be installed"
stable=$(oc get packagemanifests $kto -o jsonpath="{range .status.channels[*]}Channel: {.name} currentCSV: {.currentCSV}{'\n'}{end}" | grep stable | awk '{print $4}')
echo $stable
#only use stable channel for t8c-tsc-client-certified and latest version available
curl -O https://raw.githubusercontent.com/shawsers/random/main/TSC/tsc-operator.yaml
sed "s|startingCSV: .*$|startingCSV: $stable|" tsc-operator.yaml > tsc-op.yaml
echo""
echo "Verifying Certified Operator"
vo=$(oc get packagemanifests $kto -o jsonpath={.status.catalogSource})
#output should be "certified-operators"
echo $vo
echo ""
echo "Verifying Source is Openshift Marketplace"
vom=$(oc get packagemanifests $kto -o jsonpath={.status.catalogSourceNamespace})
#output should be "openshift-marketplace"
echo $vom
echo ""
echo "Creating turbo-tsc project/namespace to deploy TSC into"
oc create ns turbo-tsc
echo ""
echo "Deploying Certified TSC from OperatorHub"
###apply tsc-operator-group.yaml file and update it as needed with all details
curl -O https://raw.githubusercontent.com/shawsers/random/main/TSC/tsc-operator-group.yaml
oc apply -f tsc-operator-group.yaml
read -s -n 1 -t 5
###apply updated tsc-op.yaml file which deploys the certified and latest version of TSC from OperatorHub
oc apply -f tsc-op.yaml
read -s -n 1 -t 15
echo "Waiting for TSC operator to start..."
pcount=$(oc get pods -n turbo-tsc |wc -l)
while [ $pcount -lt 1 ]
do
  read -s -n 1 -t 2
  pcount=$(oc get pods -n turbo-tsc |wc -l)
done
echo ""
gko=$(oc get pods -n turbo-tsc | grep t8c | awk '{print $1}')
oc wait --for=condition=Ready pod/$gko --timeout=-1s -n turbo-tsc
echo ""
echo "TSC operator started"
echo ""
echo "Deploying TSC client via operator..."
#add info on deploying TSC client
#oc apply -f kt.yaml
echo ""
echo "Waiting for TSC client to start..."
read -s -n 1 -t 15
kcount=$(oc get pods -n turbo-tsc |wc -l)
while [ $kcount -lt 2 ]
do
  read -s -n 1 -t 2
  kcount=$(oc get pods -n turbo-tsc |wc -l)
done
echo ""
gka=$(oc get pods -n turbo-tsc | grep kube | awk '{print $1}')
#oc wait --for=condition=Ready pod/$gka --timeout=-1s -n turbo-tsc
echo ""
echo "TSC client started"
echo ""
oc get pods -n turbo-tsc
echo ""
echo "Script done"
echo ""
