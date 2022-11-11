###Step 1 - apply oc adm policy
###Step 2 - enable timescale db (must be aligned with nginx: and you must update the runAsUser: value to match your fsGroup: value)
###Step 3 - wait for the timescaledb pod to be 1/1
###Step 3 - enable grafana and extractor (must be aligned with nginx)
