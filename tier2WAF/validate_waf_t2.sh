#!/bin/bash
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin/"

function passwd() {
  echo | awk '{print $1}' /config/mypass
}

dfl_mgmt_port=`tmsh list sys httpd ssl-port | grep ssl-port | sed 's/ssl-port //;s/ //g'`

# check that the data groups have been populated
failed=0
until [[ $record_count -ge "6" ]] || [[ $failed -eq "30" ]]; do
     failed=$(($failed + 1))
     record_count=0
     for group in applianceid appmap eventhub; do
          records=$(curl -sku admin:$(passwd) -X GET -H "Content-Type: application/json" https://localhost:$dfl_mgmt_port/mgmt/tm/ltm/data-group/internal/${group}_datagroup | jq .records | jq length)
          (( record_count += records ))
     done
     sleep 10
done

if [ $? -eq 0 ]; then
    echo "Data groups ready, continuing..."
else
    echo "Data groups not ready, exiting..."
    exit 1
fi

# check that the remote logging pool is populated
failed=0
until [[ "$(curl -sku admin:$(passwd) -X GET -H "Content-Type: application/json" https://localhost:$dfl_mgmt_port/mgmt/tm/ltm/pool/~Common~azure-log.app~azure-log_remote/members | jq -r .items[0].fqdn.autopopulate | grep "enabled")" ]] || [[ $failed -eq "30" ]]; do
     failed=$(($failed + 1))
     sleep 10
done

if [ $? -eq 0 ]; then
    echo "Remote logging ready, continuing..."
else
    echo "Remote logging not ready, exiting..."
    exit 1
fi

# disable eventhub datagroup icall handler
response_code=$(curl -sku admin:$(passwd) -w "%{http_code}" -X PUT -H "Content-Type: application/json" https://localhost:$dfl_mgmt_port/mgmt/tm/sys/icall/handler/periodic/eventhub_datagroup -d '{"interval": "1800",  "script": "eventhub_datagroup"}' -o /dev/null)

if [[ $response_code != 200  ]]; then
     echo "Failed to update eventhub iCall handler with response code '"$response_code"'"
fi

# save the config
response_code=$(curl -sku admin:$(passwd) -w "%{http_code}" -X POST -H "Content-Type: application/json" https://localhost:$dfl_mgmt_port/mgmt/tm/sys/config -d '{"command": "save"}' -o /dev/null)

if [[ $response_code != 200  ]]; then
     echo "Failed to save the configuration with response code '"$response_code"'"
fi

echo "Verification complete."
exit