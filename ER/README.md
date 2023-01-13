## Instructions to correctly copy the command and code examples below
- Use the copy button to the right of the code you need to copy to have it automatically copy the code to your clipboard, which you can then paste as needed.  See example screen shot below of how to use the copy button, which only appears when you hover your mouse over the code.
<img width="1033" alt="Screenshot 2023-01-13 at 10 45 31 AM" src="https://user-images.githubusercontent.com/53303655/212361132-5cc283af-adc2-4d6e-aac0-c8513ae5b9c6.png">

#### Step 1
- Connect to your OpenShift Cluster via command line (copy the full oc login command and paste in command line to connect).  Once connected to your cluster use the copy button to copy the command below, making sure to replace "YOUR_PROJECT_HERE" with your project/namespace that you deployed Turbo into.  If you don't then enabling reporting will not work.
```
oc adm policy add-scc-to-group anyuid system:serviceaccounts:YOUR_PROJECT_HERE
```

#### Step 2
- update your xl-release yaml with the contents below using the copy button.  Make sure to update lines that start with "runAsUser: " below by replacing the number 1000##0000 in the example below with your actual "fsGroup: " value in your current xl-release yaml.  Note that the line 1 and line 3 should align with the probes you have added in your yaml, if not then enabling reporting will not work.
```
  timescaledb:
    enabled: true
  postgresql:
    persistence:
      size: 500Gi
    securityContext:
      runAsUser: 1000##0000
    volumePermissions:
      enabled: true
      securityContext:
        runAsUser: 1000##0000
```

#### Step 3
- wait until the timescaledb pod shows Ready 1/1 before proceeding to the next stop.  This is important to wait, otherwise reporting might not enable correctly and have errors.

#### Step 4
- update your xl-release yaml again with the script contents below using the copy button.  Note that the properties, grafana, extractor and reporting lines should all align with the probes you have added in your yaml.  Make sure, as if they are not enabling reporting will not work.
```
  properties:
    extractor:
      grafanaAdminPassword: vmturbo
  grafana:
    adminPassword: vmturbo
    enabled: true
    grafana.ini:
      database:
        password: vmturbo
        type: postgres
  extractor:
    enabled: true
  reporting:
    enabled: true
```

#### Step 5
- wait until the grafana and extractor pods to show as Ready 1/1 before proceeding.

#### Step 6
- delete the api pod and wait for it to become Ready 1/1

#### Step 7
- now login to your Turbo UI and you should see the REPORT option on the left menu now, which you can click to view Embedded Reports.
