#!/usr/bin/env bash
set -eu

# Settings
INSTALL_DIR=/opt/iptables
SCRIPT=iptables_country_block.sh

# Env
DATETIME='echo -n $(date +%Y-%m-%d\ %H:%M:%S)'

echo
echo "Start uninstalling iptables country block at" $(eval $DATETIME)

# Files
echo -n "Removing '$INSTALL_DIR' directory ... "
rm -rf $INSTALL_DIR
echo "OK"

# Cron
echo -n "Removing cron job ... "
CRON_FILE=/tmp/cron.jobs
crontab -l > $CRON_FILE
sed -i "/$SCRIPT/d" $CRON_FILE
crontab $CRON_FILE
rm $CRON_FILE
echo "OK"

echo "--- cron jobs ---"
crontab -l
echo "--- cron jobs ---"

# Routing
echo -n "Checking chain ... "
result=0 && iptables -C INPUT -j COUNTRY_BLOCK > /dev/null 2>&1 || result=$? || true
echo "OK"

if [ $result -eq 0 ]; then
    echo -n "Cleaning chain ... "
    iptables -D INPUT -j COUNTRY_BLOCK
    iptables -F COUNTRY_BLOCK
    iptables -X COUNTRY_BLOCK
    echo "OK"
fi

echo "Finish uninstalling iptables country block at" $(eval $DATETIME)
