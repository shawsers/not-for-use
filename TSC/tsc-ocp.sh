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
sed "s|startingCSV: .*$|startingCSV: $stable|" operator.yaml > op.yaml
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
echo "Creating turbo project/namespace to deploy TSC into"
oc create ns turbo
echo ""
echo "Deploying Certified TSC from OperatorHub"
###apply operator-group.yaml file and update it as needed with all details
oc apply -f operator-group.yaml
read -s -n 1 -t 5
###apply op.yaml file which deploys the certified TSC from OperatorHub
oc apply -f op.yaml
read -s -n 1 -t 15
echo "Waiting for TSC operator to start..."
pcount=$(oc get pods -n turbo |wc -l)
while [ $pcount -lt 1 ]
do
  read -s -n 1 -t 2
  pcount=$(oc get pods -n turbo |wc -l)
done
echo ""
gko=$(oc get pods -n turbo | grep t8c | awk '{print $1}')
oc wait --for=condition=Ready pod/$gko --timeout=-1s -n turbo
echo ""
echo "TSC operator started"
echo ""
echo "Deploying TSC agent via operator..."
oc apply -f kt.yaml
echo ""
echo "Waiting for TSC agent to start..."
read -s -n 1 -t 15
kcount=$(oc get pods -n turbo |wc -l)
while [ $kcount -lt 2 ]
do
  read -s -n 1 -t 2
  kcount=$(oc get pods -n turbo |wc -l)
done
echo ""
gka=$(oc get pods -n turbo | grep kube | awk '{print $1}')
oc wait --for=condition=Ready pod/$gka --timeout=-1s -n turbo
echo ""
echo "TSC agent started"
echo ""
oc get pods -n turbo
echo ""
echo "Script done"
echo ""
