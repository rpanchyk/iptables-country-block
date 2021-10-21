#!/usr/bin/env bash
set -eu

# Settings
INSTALL_DIR=/opt/iptables
SCRIPT=iptables_country_block.sh
SCRIPT_ARGS='"ro tr" "udp" "9987"'

# Env
DATETIME='echo -n $(date +%Y-%m-%d\ %H:%M:%S)'

echo
echo "Start installing iptables country block at" $(eval $DATETIME)

# Keep current dir and goto this script dir
CURRENT_DIR=$(pwd)
cd "$(dirname $0)"

# Prepare
[ ! -d $INSTALL_DIR ] && mkdir -p $INSTALL_DIR
chmod +x $SCRIPT

# Install script
echo -n "Copying '$SCRIPT' to '$INSTALL_DIR' ... "
cp -f $SCRIPT $INSTALL_DIR
echo "OK"

# Cron
echo -n "Adding cron job ... "
CRON_FILE=/tmp/cron.jobs
crontab -l > $CRON_FILE
sed -i "/$SCRIPT/d" $CRON_FILE # remove old job if any
echo "0 2 * * mon $INSTALL_DIR/$SCRIPT $SCRIPT_ARGS >> $INSTALL_DIR/cron.log" >> $CRON_FILE 2>&1
crontab $CRON_FILE
rm $CRON_FILE
echo "OK"

echo "--- cron jobs ---"
crontab -l
echo "--- cron jobs ---"

# Back to previously standing dir
cd "$CURRENT_DIR"

echo "Finish installing iptables country block at" $(eval $DATETIME)
