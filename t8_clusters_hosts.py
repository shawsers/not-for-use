#this script works in Turbonomic v8/XL only
import requests
import urllib3
import csv
import json
import glob
import time
from datetime import datetime as DT
from requests.exceptions import HTTPError
from urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings()
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

#Put Turbo 8/XL server name here
xl_server = "https://xl1.demo.turbonomic.com/api/v3/"
url1 = xl_server + "login?hateoas=true"
#update with your UI username and password below to access Turbo
payload = {'username': 'USERNAME',
'password': 'PASSWORD'}
files = [

]
s = requests.Session()
response = s.post(url1, data = payload, files = files, verify=False)
if response.status_code == 200:
    content = response.content.decode("utf8")
    js = json.loads(content)
    authToken = js["authToken"]
else:
    print(str(DT.now()), "API Call Failed:", response.status_code, "\n", response.text)

urlh = xl_server + "search/?ascending=true&disable_hateoas=true&order_by=name&q="
data = {"criteriaList":[],"logicalOperator":"AND","className":"Cluster","scope":None}
clusterlist = s.post(urlh, headers={'content-type': 'application/json', 'Authorization':authToken}, data = json.dumps(data), verify=False)
clusterlistj = clusterlist.json()
#print(clusterlistj)
with open('All_Cluster_Host_Entities.csv', 'w') as cent:
    print ("**Starting csv output")
    oum = "Entity ID","Entity Name","Entity Type","State","Cluster Name","Target Name","Target Category","Target Type"
    csvwriter = csv.writer(cent)
    csvwriter.writerow(oum) 
    for listc in clusterlistj:
        #print(listc["displayName"])
        cuuid = listc["uuid"]
        clustern = listc["displayName"]
        #print(cuuid)
        urlcm = xl_server + "groups/" + cuuid + "/members"
        cmembers = s.get(urlcm, headers={'content-type': 'application/json', 'Authorization':authToken}, verify=False)
        cmemberj = cmembers.json()
        #print (cmemberj)
        for cmem in cmemberj:
            #for cons in cmem["consumers"]:
            if cmem["className"] == "PhysicalMachine":
            #for cons in hosts:
                euid = cmem["uuid"]
                    #urle = xl_server + "entities/" + euid + "/aspects"
                    #entity = s.get(urle, headers={'content-type': 'application/json', 'Authorization':authToken}, verify=False)
                    #entityr = entity.json()
                    #os = entityr["virtualMachineAspect"]["os"]
                outt = (cmem["uuid"],cmem["displayName"],cmem["className"],cmem["state"],listc["displayName"],cmem["discoveredBy"]["displayName"],cmem["discoveredBy"]["category"],cmem["discoveredBy"]["type"])
                csvwriter = csv.writer(cent)
                csvwriter.writerow(outt) 
                host = cmem["displayName"]
                print('  writing output for Host: ' + host + " in Cluster: " + clustern)
    print ("**SCRIPT COMPLETE - check file name: All_Cluster_Host_Entities.csv")