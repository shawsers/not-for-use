#### Step 1
- Connect to your OpenShift Cluster via command line (copy login command and paste the token).  Once connected to your cluster run oc adm command replacing "YOUR_PROJECT_HERE" with the project/namespace that you deployed Turbo into.  [Step 1 file is here - use the "copy raw contents" button on the top right of the file to copy the contents](https://github.com/shawsers/random/blob/main/ER/Step1-oc-adm.yaml)
```
oc adm policy add-scc-to-group anyuid system:serviceaccounts:YOUR_PROJECT_HERE
```

#### Step 2
- update your xl-release yaml with the content in the 2nd yaml file.  Make sure to update lines 7 and 11 by replacing the number 1000760000 in the file with your fsGroup value in your yaml.  Note that the line 1 and line 3 should align with the probes you have added in your yaml.  [Step 2 file is here - use the "copy raw contents" button on the top right of the file to copy the contents](https://github.com/shawsers/random/blob/main/ER/Step2-timescaledb.yaml)

#### Step 3
- wait until the timescaledb pod shows Ready 1/1 before proceeding.

#### Step 4
- update your xl-release yaml again with the content in the 3rd yaml file.  Note that the properties, grafana, extractor and reporting lines should all align with the probes you have added in your yaml.  [Step 3 file is here - use the "copy raw contents" button on the top right of the file to copy the contents](https://github.com/shawsers/random/blob/main/ER/Step3-grafana-extractor.yaml)

#### Step 5
- wait until the grafana and extractor pods to show as Ready 1/1 before proceeding.

#### Step 6
- delete the api pod and wait for it to become Ready 1/1

#### Step 7
- now login to your Turbo UI and you should see the Report option on the left menu now.
