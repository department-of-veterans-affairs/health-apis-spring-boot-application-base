#!/usr/bin/env bash

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
java -jar $(find .  -type f -name "$AWS_APP_NAME-*.jar" | head -1)
