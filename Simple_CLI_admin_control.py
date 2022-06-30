import urllib.parse

import urllib.request

def submitInformation(url,parameters):
    encodedParams = urllib.parse.urlencode(parameters).encode("utf-8")
    req = urllib.request.Request(url)
    net = urllib.request.urlopen(req,encodedParams)
    print(net.read())
    return(net.read())

enter_url = input("enter url : ")

print("""

select option

[1] scan
[2] kick
[3] banned
[4] unbanned
[5] request url

""")

option = input("enter option : ")

parameters = {'authentication':'random'}
info = submitInformation(enter_url,parameters)

authentication = input("enter authentication : ")
parameters = {'authentication':authentication}
info = submitInformation(enter_url,parameters)

if (option == "1"):

     parameters = {'scan':'avatar'}
     info = submitInformation(enter_url,parameters)

if (option == "2"):

     uuid = input("enter uuid : ")

     parameters = {'kick':uuid}
     info = submitInformation(enter_url,parameters)


if (option == "3"):

     uuid = input("enter uuid : ")

     parameters = {'banned':uuid}
     info = submitInformation(enter_url,parameters)

if (option == "4"):

     uuid = input("enter uuid : ")

     parameters = {'unbanned':uuid}
     info = submitInformation(enter_url,parameters)
     
if (option == "5"):

     parameters = {'request':'url'}
     info = submitInformation(enter_url,parameters)
     
else:

     exit()
