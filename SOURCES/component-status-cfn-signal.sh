#!/bin/bash -x

# beginning of app testing loop
# edit the contents of the next two lines to define a specific test for your application
until [ "$status" == "200" ]; do
status=$(curl --write-out %{http_code} --output /dev/null --silent http://localhost:8080/status );
sleep 5;
done
# end of app testing loop

# We should only reach here if the check above has confirmed that the app is up
# resource should be set to the Logical Resource id of the instances AutoScalingGroup
/usr/bin/cfn-signal --stack="${STACKID}" --region="${REGION}" --resource="ApplicationAutoScalingGroup" --success=true