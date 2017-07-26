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
# a choice for which one. 

domainsList=($(curl -s -X GET "https://api.cloudflare.com/client/v4/zones" 
                    -H "X-Auth-Email: EMAIL" 
                    -H "X-Auth-Key: APIKEY" 
                    -H "Content-Type: application/json" | 
                    grep -Po '{*"name":"(.*?)"' |  awk -F'[":]' '/\.[a-z].*/ { print $5 }'))
                    
domainRequest() 
{
            C=1
            for NUM in "${domainsList[@]}"
            do 
               printf "%2d. %-20s\n" "$C" "$NUM"
               ((C=C+1))
            done
}

printf "Choose which of the following domains: \n%-20s\n" "$(domainRequest)"
read domainNumber

grab_devmode=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/ZONEID/settings/development_mode" -H "X-Auth-Email: EMAIL" -H "X-Auth-Key: APIKEY" -H "Content-Type: application/json" |sed 's|[{"]||g' | awk -F'[:,]' '{ print $3 " is " $5 }');

echo "The current status of ${grab_devmode}";

dev_settings ()
{

echo "Would you like to turn DevMode On or Off?";
read settingsMode;

echo "You selected turn DevMode ${settingsMode}"; echo;

 if [[ "$settingsMode" = on ]]; then
    echo "Turning DevMode On";
    4devmode_ON=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/ZONEID/settings/development_mode" \
    -H "X-Auth-Email: EMAIL" \
    -H "X-Auth-Key: APIKEY" \
    -H "Content-Type: application/json" \
    --data '{"value":"on"}');
    devClean=($(echo "${devmode_ON}" | sed 's|[{"]||g' | awk -F'[:,]' '{ print $3 " is " $5 }'));
    echo "${devClean[@]}, page results will no longer be cached.";

 elif [[ "$settingsMode" = off ]]; then
    echo "Turning DevMode Off"
    devmode_OFF=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/ZONEID/settings/development_mode" \
    -H "X-Auth-Email: EMAIL" \
    -H "X-Auth-Key: APIKEY" \
    -H "Content-Type: application/json" \
    --data '{"value":"off"}')
    devClean=($(echo "${devmode_OFF}" | sed 's|[{"]||g' | awk -F'[:,]' '{ print $3 " is " $5 }'));
    echo "${devClean[@]}, page results are being cached."

 else
    echo "You entered the wrong information, go back and try again.";
fi

  }

dev_settings;
    
