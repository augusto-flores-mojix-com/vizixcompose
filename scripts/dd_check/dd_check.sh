#!/bin/bash
#set -e

# Notification vars
#SLACK_HOOK=${SLACK_HOOK:=''}
#SLACK_SUCCESS=${SLACK_SUCCESS:=false}
#SLACK_FAIL=${SLACK_FAIL:=false}
PD_FAIL=${PD_FAIL:=true}
PD_KEY=${PD_KEY:=''} # PD API KEY
PD_API=${PD_API:='https://events.pagerduty.com/generic/2010-04-15/create_event.json'}

# Data vars
DATADOG_API_TOKEN= #TOKEN
DATADOG_METRIC_NAME=execTime-TENANT-REPORTNAME
HOST=mojix-retail-io
TAG=$HOST
currenttime=$(date +%s)
CURRENT=$(date +"%Y-%m-%d")
PAST_DAY=$(date --date="$CURRENT 1 day ago" +"%F")
PAST_MONTH=$(date --date="$CURRENT 1 month ago" +"%F")
PAST_MONTH_ADD=$(date --date="$PAST_MONTH +1 days" +"%F")
START=$(date --date="$PAST_MONTH_ADD" "+%s%N" | cut -b1-13)
END=$(date --date="$PAST_DAY 23:59:59.99" "+%s%N" | cut -b1-13)
#DATA=$(curl -sk -X POST https://bpk.vizixcloud.com/riot-core-services/api/reportExecution/mongo/201 -H 'Content-Type: application/json' -H 'api_key: XXXXXXXX' -d '{"Thing Type":"4","Thing Owner Group":"true","Thing Facility Map":"false","UTC Offset (+/- hours)":"8"}' | cut -d '"' -f4)
DATA=$(curl -s "https://pe.mojixretail.io/riot-core-services/api/reportExecution/ANALYTICS_SOURCE_DAILYSTATSSOURCE?pageSize=-1&pageNumber=1&includeResults=true&includeTotal=false&reportHierarchyGroupCode=%3EPE" -H "content-type: application/json" -H "apikey: XXXXXXXXXXXXXXXXXX" --data-binary '{"Retail_Date":"{\"relativeDate\":\"CUSTOM\",\"startDate\":\"'"$START"'\",\"endDate\":\"'"$END"'\"}","Retail_StoreNumber":"","orderByColumn":1,"sortProperty":"ASC"}' --max-time 25)
DATA_EVAL=$(echo $DATA | jq '.reportExecutionTime')

# error to PagerDuty
pd_error() {
curl --silent -X POST $PD_API -H 'Content-Type: application/json' --data '{"service_key": "'"$PD_KEY"'", "event_type": "trigger", "description": "'"$DATADOG_METRIC_NAME"' Failure", "details": {"Error Code": "'"$?"'", "details": "'"$DATA_EVAL"'"}}'
exit 1
}

# post to DD
dd_post() {
curl -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
         [{\"metric\":\"vizix.$DATADOG_METRIC_NAME\",
          \"points\":[[$currenttime, $DATA_EVAL]],
          \"type\":\"gauge\",
          \"host\":\"$HOST.$DATADOG_METRIC_NAME\",
          \"tags\":[\"$TAG\"]}
        ]
    }" \
'https://app.datadoghq.com/api/v1/series?api_key='$DATADOG_API_TOKEN''
echo "$curenttime|$DATA_EVAL"
exit 0
}

if [ -z "$DATA" ]; then
   pd_error
fi

if [ -z "$DATA_EVAL" ]; then
   pd_error
fi

if [ $DATA_EVAL = 'null' ]; then
   pd_error
fi

dd_post
