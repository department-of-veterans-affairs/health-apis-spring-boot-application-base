#!/usr/bin/env bash

#
# Get files off s3 bucket
#
[ -z "$AWS_CONFIG_FOLDER" ] && AWS_CONFIG_FOLDER=$AWS_APP_NAME
aws s3 cp s3://$AWS_BUCKET_NAME/$AWS_CONFIG_FOLDER/ /opt/va/ --recursive
aws s3 cp s3://$AWS_BUCKET_NAME/system_certs/ /opt/va/certs --recursive
aws s3 cp s3://$AWS_BUCKET_NAME/krb5/krb5.conf /etc


#
# Start up app and log activity
# If a start up hook exeists, execute it
#
cd /opt/va/

HOOK=on-start.sh
if [ -f $HOOK ]
then
  echo ============================================================
  echo "Running start up HOOK"
  chmod +x $HOOK
  ./$HOOK
  HOOK_STATUS=$?
  [ $HOOK_STATUS != 0 ] && echo "Start up hook failed with status $HOOK_STATUS" && exit 1
fi

echo ============================================================
exec java -jar $(find .  -type f -name "$AWS_APP_NAME-*.jar" | head -1) $@
