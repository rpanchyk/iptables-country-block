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
The execution command looks like:
```
iptables_country_block.sh "<COUNTRIES>" "<PROTOCOL>" "<PORT>"
```
where:
- `<COUNTRIES>` - is whitespace separated lowercase two-letter ISO country codes.
- `<PROTOCOL>` - protocol from `/etc/protocols` file or just use `all` keyword to match everything.
- `<PORT>` - desired port number to block.

## Usage examples
Let's imagine you have finally to block `Russia` and `North Korea` from your SSH server.

### Case 1: Run with `console` output
```bash
sudo ./iptables_country_block.sh "ru kp" "tcp" "22"
```

### Case 2: Run with `log-file` output
```bash
sudo sh -c './iptables_country_block.sh "ru kp" "tcp" "22" >> /var/log/country_block.log'
```

Now users (hackers) from those countries should not be able to bother you anymore.

## Automation
Additional scripts allow to setup **fully autonomous** processing.

### Install for automatic execution by cron
```bash
sudo ./host/iptables/install.sh
```

### Uninstall (remove files and cron job)
```bash
sudo ./host/iptables/uninstall.sh
```

## Resources
There are alot of info about `iptables` configuration, so just a couple of them:
- [Common Firewall Rules and Commands](https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands)
- [How To List and Delete Iptables Firewall Rules](https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules)

Basically this script is inspired by:
- [Link 1](https://www.clearos.com/clearfoundation/social/community/how-to-easily-block-whole-country-s-with-iptables)
- [Link 2](https://www.cyberciti.biz/faq/block-entier-country-using-iptables/)

Also, there are interesting resources for resolving country IP ranges:
- [geoip.site](https://geoip.site)
- [countryipblocks.net](https://www.countryipblocks.net/acl.php)
- [services.ce3c.be](http://services.ce3c.be/ciprg/)

## Improvements
Probably the most reasonable would be to use [ip2location.com](https://download.ip2location.com/lite/) IP database which is full and fresh (monthly updated). No ads, but they are just great.

See [ip-address-ranges-by-country](https://lite.ip2location.com/ip-address-ranges-by-country) page to check provided country IP ranges.
