# Block all traffic from specific countries

## About
This bash script allows to set blocking rules in [iptables](https://www.netfilter.org/projects/iptables/index.html) firewall.

It downloads country specific IP ranges from [www.ipdeny.com/ipblocks](http://www.ipdeny.com/ipblocks)
 for the **specified country** and creates **blocking rule** in chain per each IP range.

In short, the idea is to set blocking rule like:
```bash
iptables -N COUNTRY_BLOCK
iptables -I INPUT -j COUNTRY_BLOCK
iptables -A COUNTRY_BLOCK --source <IP> --protocol <PROTOCOL> --dport <PORT> -j DROP
```
Note: within the script `DROP` policy is used, but you can replace it with `REJECT` if needed.

## Prerequisites
You should be able to run this script via `sudo` or be a `root` user.

## Dependencies
The following packages (utils) must be installed on local machine:
- bash
- iptables
- wget
- egrep

## Usage instructions
Script accepts only one argument but with specific notation by groups.

The execution command looks like:
```bash
iptables_country_block.sh "<COUNTRIES>:<PROTOCOL>:<PORT>|<COUNTRIES>:<PROTOCOL>:<PORT>"
```

Groups are separated by pipes (`|`).

Items inside the group are separated by colons (`:`) in order:
- First item - comma separated two-letter ISO country codes in lowercase
- Second item - protocol, see possible values in `/etc/protocols` or use `all` keyword to match everything
- Third item - destination port

## Usage examples
Let's imagine you have finally to block `Russia` and `North Korea` from your FTP and HTTP(S) servers.

### Option 1: Run with `console` output
```bash
sudo ./iptables_country_block.sh "ru,kp:tcp:21|ru,kp:tcp:80"
```

### Option 2: Run with `log-file` output
```bash
sudo sh -c './iptables_country_block.sh "ru,kp:tcp:21|ru,kp:tcp:80" >> /var/log/country_block.log'
```

Now users (hackers) from those countries should not be able to bother you anymore.

## Automation
Additional scripts allow to setup **fully autonomous** processing.

### Install for automatic execution by cron
```bash
sudo ./install.sh
```

### Uninstall (remove files and cron job)
```bash
sudo ./uninstall.sh
```

## Resources
Basically this script is inspired by:
- [Link 1 - clearos.com](https://www.clearos.com/clearfoundation/social/community/how-to-easily-block-whole-country-s-with-iptables)
- [Link 2 - cyberciti.biz](https://www.cyberciti.biz/faq/block-entier-country-using-iptables/)

There are alot of info about `iptables` configuration, so just a couple of them:
- [Common Firewall Rules and Commands](https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands)
- [How To List and Delete Iptables Firewall Rules](https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules)

Also, there are interesting resources for resolving country IP ranges:
- [geoip.site](https://geoip.site)
- [countryipblocks.net](https://www.countryipblocks.net/acl.php)
- [services.ce3c.be](http://services.ce3c.be/ciprg/)

## Improvements
Probably the most reasonable would be to use [ip2location.com](https://download.ip2location.com/lite/) IP database which is full and fresh (monthly updated). No ads, but they are just great.

See [ip-address-ranges-by-country](https://lite.ip2location.com/ip-address-ranges-by-country) page to check provided country IP ranges.
