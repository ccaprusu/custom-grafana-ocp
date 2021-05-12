#!/bin/bash

# MSP groups, rota and associate, (34846, 34847)
MSP_USERS_LIST=$(curl -H "Authorization: Bearer 1FTPK5ZFFftbI1VDtktZwtrc72In9YsKlzU6HpRkJaMbkZjPIArHzhyAzXIiLg8R" -X GET "https://api.rotacloud.com/v1/users" | jq -c '.[] | select( .group == 34846 )| { "id": .id, "first_name": .first_name, "last_name": .last_name, "email": .email, "phone": .secondary_phone, "group": .group }')
MSP_ASSOCIATES_LIST=$(curl -H "Authorization: Bearer 1FTPK5ZFFftbI1VDtktZwtrc72In9YsKlzU6HpRkJaMbkZjPIArHzhyAzXIiLg8R" -X GET "https://api.rotacloud.com/v1/users" | jq -c '.[] | select( .group == 34847 )| { "id": .id, "first_name": .first_name, "last_name": .last_name, "email": .email, "phone": .secondary_phone, "group": .group }')

# Get actual hour
NOW_HOUR=$(TZ='Europe/Madrid' date +%H) # Must coincide with the time the shift starts, so a cronjob is needed at 06:00, 14:00 and 22:00

# Hour correction for the next Rotacloud API query USER_ON_SHIFT
if [[ ${NOW_HOUR#0} -gt 05 && ${NOW_HOUR#0} -lt 14 ]]
then
   NOW_HOUR=06
else 
  if [[ ${NOW_HOUR#0} -gt 13 && ${NOW_HOUR#0} -lt 22 ]]
  then
       NOW_HOUR=14
  else NOW_HOUR=22
  fi
fi

NOW_EPOCH=$(TZ='Europe/Madrid' date -d $NOW_HOUR +"%s")


SHIFT_INCREMENT=28800
START_SHIFT=$NOW_EPOCH
END_SHIFT=$(( START_SHIFT + SHIFT_INCREMENT ))

# Get user entering the shift
USERS_ON_SHIFT=$(curl -H "Authorization: Bearer 1FTPK5ZFFftbI1VDtktZwtrc72In9YsKlzU6HpRkJaMbkZjPIArHzhyAzXIiLg8R" -X GET "https://api.rotacloud.com/v1/shifts?start=$START_SHIFT&end=$END_SHIFT&include_deleted=false" | jq '.[]| .user')

# Filter users list on shift to match Infrastructure Engineers and disscard associates

# If there are more than one guys on the shift, either associate and engineer, or 2 or more engineers
if [[ $(echo $USERS_ON_SHIFT|wc -w) -gt 1 ]]
then
      for USER_ID in $(echo $USERS_ON_SHIFT)
      do 
          USER_ON_SHIFT=$USER_ID
          USER_NAME=$(echo $MSP_USERS_LIST|jq -c ". |select(.id == $USER_ID) | .first_name "| cut -d '"' -f2)
          #Âif username is not in the MSP_USERS_LIST, must be an associate.
          if [[ $USER_NAME != "" ]] 
          then
                  USER_NAME=$(echo $MSP_USERS_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .first_name "| cut -d '"' -f2)
                  USER_LAST_NAME=$(echo $MSP_USERS_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .last_name "| cut -d '"' -f2)
                  PHONE_NUMBER=$(echo $MSP_USERS_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .phone "| cut -d '"' -f2)
               if [[ ${PHONE_NUMBER#0} -ne "null" ]]
               then
                     break
               else
                     continue
               fi
          fi
      done
# else there must be either one engineer or one associate
else 
          USER_ON_SHIFT=$USERS_ON_SHIFT
          USER_NAME=$(echo $MSP_USERS_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .first_name "| cut -d '"' -f2)
          # if username is not in the MSP_USERS_LIST, must be an associate.
          if [[ $USER_NAME != "" ]]
          then
                  USER_NAME=$(echo $MSP_USERS_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .first_name "| cut -d '"' -f2)
                  USER_LAST_NAME=$(echo $MSP_USERS_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .last_name "| cut -d '"' -f2)
                  PHONE_NUMBER=$(echo $MSP_USERS_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .phone "| cut -d '"' -f2)
          else
                  USER_NAME=$(echo $MSP_ASSOCIATES_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .first_name "| cut -d '"' -f2)
                  USER_LAST_NAME=$(echo $MSP_ASSOCIATES_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .last_name "| cut -d '"' -f2)
                  PHONE_NUMBER=$(echo $MSP_ASSOCIATES_LIST|jq -c ". |select(.id == $USER_ON_SHIFT) | .phone "| cut -d '"' -f2)
         fi
fi
 
# Launch python script that changes the phone number on callture
LOG=$(/usr/bin/python ./callture.py ${PHONE_NUMBER} 2>&1)

# Log to mail

[[ -z "$LOG" ]] && echo -e "Next shift: $USER_NAME $USER_LAST_NAME \nStarting at: ${NOW_HOUR}h \nPhone number: $PHONE_NUMBER \n`TZ='Europe/Madrid' date` \n\nLog errors: ${LOG}" | mailx -S "from=MSP Automations<msp-automations@crossvale.com>" -s "Callture - Phone number changed" callture-logs@crossvale.com ||	echo -e "Next shift: $USER_NAME $USER_LAST_NAME \nStarting at: ${NOW_HOUR}h \nPhone number: $PHONE_NUMBER \n`TZ='Europe/Madrid' date` \n\nLog errors: ${LOG}" | mailx -S "from=MSP Automations<msp-automations@crossvale.com>" -s "Callture - Phone number change failed!" callture-logs@crossvale.com
