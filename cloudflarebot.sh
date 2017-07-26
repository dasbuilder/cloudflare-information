#!/bin/bash
#####################################################
# Original script written by Spencer Anderson       #
#####################################################
#
#####################################################
#               Version History                     #
#####################################################
#         -+- Version 0.1 - April 2017 -+-          #
# Allows user to turn on or off developer mode for  #
# the website thespenceitgroup.com.                 #
#                                                   #
#         -+- Version 0.2 - July 2017 -+-           #
# Users now see which domains they have in their    #
# Cloudflare account.                               #
#####################################################


echo "==============================================================";
echo "========+ Welcome to Cloudflare Settings Bot v0.2 +===========";
echo "==============================================================";
echo;

# This function prints current domains on the account and gives the user
# a choice for which one. This will be run through python to get the
# required information.
# This part is still under construction at this time. 

cat << EOF > zoneGet.py
#!/usr/bin/env python3
#!/usr/local/bin/env python3
import requests
import json

email = "your@email.com"
authKey = "Cloudflare API Key"
passed = { "X-Auth-Email": email,
            "X-Auth-Key": authKey,
            "Content-Type": "application/json"
}

print("Retrieving names now")
domainGrab = requests.get("https://api.cloudflare.com/client/v4/zones", headers=passed)
domainsInfo = json.loads(domainGrab.text)

def domPrinter():

    print("Domains: ")
    for domainslist in domainsInfo['result']:
    print(domainslist['name'])
    

grab_devmode=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/40f8115c5f06014a8caf13d644664362/settings/development_mode" -H "X-Auth-Email: se_anderson@windstream.net" -H "X-Auth-Key: 54fbd66aede37f2bd13dd7418de3afcffb4c6" -H "Content-Type: application/json" |sed 's|[{"]||g' | awk -F'[:,]' '{ print $3 " is " $5 }');

echo "The current status of ${grab_devmode}";

dev_settings ()
{

echo "Would you like to turn DevMode On or Off?";
read settingsMode;

echo "You selected turn DevMode ${settingsMode}"; echo;

 if [[ "$settingsMode" = on ]]; then
    echo "Turning DevMode On";
    4devmode_ON=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/40f8115c5f06014a8caf13d644664362/settings/development_mode" \
    -H "X-Auth-Email: se_anderson@windstream.net" \
    -H "X-Auth-Key: 54fbd66aede37f2bd13dd7418de3afcffb4c6" \
    -H "Content-Type: application/json" \
    --data '{"value":"on"}');
    devClean=($(echo "${devmode_ON}" | sed 's|[{"]||g' | awk -F'[:,]' '{ print $3 " is " $5 }'));
    echo "${devClean[@]}, page results will no longer be cached.";

 elif [[ "$settingsMode" = off ]]; then
    echo "Turning DevMode Off"
    devmode_OFF=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/40f8115c5f06014a8caf13d644664362/settings/development_mode" \
    -H "X-Auth-Email: se_anderson@windstream.net" \
    -H "X-Auth-Key: 54fbd66aede37f2bd13dd7418de3afcffb4c6" \
    -H "Content-Type: application/json" \
    --data '{"value":"off"}')
    devClean=($(echo "${devmode_OFF}" | sed 's|[{"]||g' | awk -F'[:,]' '{ print $3 " is " $5 }'));
    echo "${devClean[@]}, page results are being cached."

 else
    echo "You entered the wrong information, go back and try again.";
fi

  }

dev_settings;
    
