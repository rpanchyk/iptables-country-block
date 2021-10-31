#!/usr/bin/env bash
set -eu

# Purpose: Block all traffic from specific countries.
# Based on http://www.cyberciti.biz/faq/?p=3402

# The script downloads IP list in CIDR format for the specified country
# and insert each IP to iptables blocking rule.

# Here are commands might be helpful along with the script.
# Save iptables rules:          sudo iptables-save > iptables.backup
# Restore iptables rules:       sudo iptables-restore < iptables.backup
# Check where chain is used:    sudo iptables -S | grep COUNTRY_BLOCK

# Settings
ARGS=$1
DOWNLOAD_URL="http://www.ipdeny.com/ipblocks/data/countries"
ZONE_DIR="/opt/iptables" # directory where zones are saved
MANUAL_ZONE="/opt/iptables/manual.zone" # custom zone

# Env
DATETIME='echo -n $(date +%Y-%m-%d\ %H:%M:%S)'

echo
echo "Start iptables country block at" $(eval $DATETIME)

echo -n "Checking requirements ... "
if [ "$#" -ne 1 ]; then
    echo "unsatisfied, illegal number of arguments. Exit."
    exit 1
fi
if [ -z $(which bash) ] || [ -z $(which iptables) ] || [ -z $(which wget) ] || [ -z $(which egrep) ]; then
    echo "unsatisfied, install 'bash, iptables, wget, egrep' utils. Exit."
    exit 1
fi
if [ $(id -u) -ne 0 ]; then
    echo "unsatisfied, user not root. Exit."
    exit 1
fi
echo "OK"

echo -n "Saving current rules ... "
BACKUP_ZONE_DIR=$ZONE_DIR/backup
[ ! -d $BACKUP_ZONE_DIR ] && mkdir -p $BACKUP_ZONE_DIR
iptables-save > $BACKUP_ZONE_DIR/iptables_$(date +%Y-%m-%d_%H-%M-%S).backup
echo "OK"

if [ ! -d $ZONE_DIR ]; then
    echo -n "Creating '$ZONE_DIR' directory ... "
    mkdir -p $ZONE_DIR
    echo "OK"
fi

echo -n "Checking chain ... "
result=0 && iptables -C INPUT -j COUNTRY_BLOCK > /dev/null 2>&1 || result=$? || true
echo "OK"
if [ $result -eq 0 ]; then
    echo -n "Ejecting chain ... "
    iptables -D INPUT -j COUNTRY_BLOCK
    echo "OK"

    echo -n "Flushing chain ... "
    iptables -F COUNTRY_BLOCK
    echo "OK"

    echo -n "Removing chain ... "
    iptables -X COUNTRY_BLOCK
    echo "OK"
fi

echo -n "Creating chain ... "
iptables -N COUNTRY_BLOCK
echo "OK"

echo -n "Injecting chain ... "
iptables -I INPUT -j COUNTRY_BLOCK
echo "OK"

for GROUP in ${ARGS//|/ }; do
    echo "Processing '$GROUP' group - start"

    IFS=':' ITEMS=($GROUP) && unset IFS
    COUNTRIES="${ITEMS[0]}"
    PROTOCOL="${ITEMS[1]}"
    PORT="${ITEMS[2]}"

    echo "COUNTRIES: $COUNTRIES"
    echo "PROTOCOL: $PROTOCOL"
    echo "PORT: $PORT"

    for COUNTRY in ${COUNTRIES//,/ }; do
        echo "Add blocking rules for '$COUNTRY' - start"

        # Local zone file
        ZONE=$ZONE_DIR/$COUNTRY.zone

        # Get fresh zone file
        wget --no-check-certificate -O $ZONE "$DOWNLOAD_URL/$COUNTRY.zone" 2>&1

        # Set rules
        IPS=$(egrep -v "^#|^$" $ZONE)
        for IP in $IPS
        do
            echo -n "Set blocking rule for '$IP' ... "
            iptables -A COUNTRY_BLOCK --source $IP --protocol $PROTOCOL --dport $PORT -j DROP
            echo "OK"
        done

        echo "Add blocking rules for '$COUNTRY' - end"
    done

    echo "Processing '$GROUP' group - end"
done

if [ -f $MANUAL_ZONE ]; then
    echo "Add manual blocking rules - start"

    # Set rules
    IPS=$(egrep -v "^#|^$" $MANUAL_ZONE)
    for IP in $IPS
    do
        echo -n "Set blocking rule for '$IP' ... "
        iptables -A COUNTRY_BLOCK --source $IP --protocol $PROTOCOL --dport $PORT -j DROP
        echo "OK"
    done

    echo "Add manual blocking rules - end"
fi

echo "Finish iptables country block at" $(eval $DATETIME)
