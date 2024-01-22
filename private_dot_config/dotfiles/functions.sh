# @file .functions
# @brief Shared functions which are sourced when shell starts
# @description
#     Helper functions for your shell. This is to be sourced not executed

# @section Shell-specifc functions
# @description Functions specific to zsh, bash or other shells
if [ -n "$ZSH_VERSION" ]; then

   # @description Clear history for the current terminal session
   # @noargs
   function clear_history
   {
      local HISTSIZE=0
   }

   # @description Debug p10k
   # @noargs
   function p10k_debug()
   { 
      emulate -L zsh -o xtrace
      typeset -pm 'POWERLEVEL9K_*|P9K_KUBECONTEXT_*|ZSH_VERSION'
      uname -a
      whence kubectl
      ((!$ + commands[kubectl])) || kubectl config view -o=yaml
   } &>/tmp/p10k.txt

   ## Reveal the command behind an alias with ZSH
   ## Surce: https://dev.to/equiman/reveal-the-command-behind-an-alias-with-zsh-4d96
   local cmd_alias=""
   if [[ -z "$ALIAS_FOR_PREFIX" ]]; then
      ALIAS_FOR_PREFIX="💡"
   fi
   
   # Reveal Executed Alias
   alias_for() {
      [[ $1 =~ '[[:punct:]]' ]] && return
      local search=${1}
      local found="$( alias $search )"
      if [[ -n $found ]]; then
         found=${found//\\//} # Replace backslash with slash
         found=${found%\'} # Remove end single quote
         found=${found#"$search="} # Remove alias name
         found=${found#"'"} # Remove first single quote
         echo "${found} ${2}" | xargs # Return found value (with parameters)
      else
         echo ""
      fi
   }

   expand_command_line() {
      first=$(echo "$1" | awk '{print $1;}')
      rest=$(echo ${${1}/"${first}"/})

      if [[ -n "${first//-//}" ]]; then # is not hypen
         cmd_alias="$(alias_for "${first}" "${rest:1}")" # Check if there's an alias for the command
         if [[ -n $cmd_alias ]] && [[ "${cmd_alias:0:1}" != "." ]]; then # If there was and not start with dot
            echo "$ALIAS_FOR_PREFIX ${c[yellow]}${cmd_alias}${c[reset]}" # Print it
         fi
      fi
   }

   pre_validation() {
      [[ $# -eq 0 ]] && return                    # If there's no input, return. Else...
      expand_command_line "$@"
   }
# elif [ -n "$BASH_VERSION" ]; then
# else
#    # assume something else
#    echo ""

fi

# @description include functions from shell helper library
# Clone https://gitlab.com/papanito/shell-helper-library to $SHELL_HELPER_LIBRARY
function loadShellHelperLibray()
{
   if [ -n "$SHELL_HELPER_LIBRARY" ] && [ -d "$SHELL_HELPER_LIBRARY" ]; then
      for filename in $(find $SHELL_HELPER_LIBRARY -name "*.sh" ); do
         source $filename
      done
   fi
}
loadShellHelperLibray

# @description See https://software.rajivprab.com/2019/07/14/ssh-considered-harmful/
# @arg $1 string name of the host
# @arg $2 string name of the tmux session
function tsh
{
   host=$1
   session_name=$2
   if [ -z "$session_name" ]; then
      echo "Need to provide session-name. Example: tsh <hostname> main"
      return 1
   fi
   ssh $host -t "tmux attach -t $session_name || tmux new -s $session_name"
}

# @description Automatically inputs aliases here in .aliases
# @arg $1 string name of alias
# @arg $2 string command to execute
function addalias()
{ 
   if [[ $1 && $2 ]]; then
      echo -e "alias $1=\"$2\"" >>~/.aliases
      alias $1=$2
   fi
}

# @description takes a screenshot of your current window
# @noargs
function shot()
{ 
   import -frame -strip -quality 75 "$HOME/$(date +%s).png"
}

# @section IRC
# @description irc helper functions

# @description To create a password-less certificate that is valid for 730 days (when requested to enter details like state or even Common Name (CN), you can fill anything you want)
# Source: https://wiki.archlinux.org/title/Irssi#Configuration
# @noargs
irssi_client_cert()
{ 
   openssl req -newkey rsa:4096 -days 730 -x509 -keyout irssi.key -out irssi.crt -nodes
   cat irssi.crt irssi.key >~/.irssi/irssi.pem
   chmod 600 ~/.irssi/irssi.pem
   rm irssi.crt irssi.key

   openssl x509 -sha512 -fingerprint -noout -in ~/.irssi/irssi.pem | sed -e 's/^.*=//;s/://g;y/ABCDEF/abcdef/'
}

# @section Proxy and Anomymization
# @description Helper functions for proxy and tor

# @description Set a proxy for the terminal using tor
# @noargs
function termproxy()
{ 
   export http_proxy='http://localhost:8118'
   export https_proxy='http://localhost:8118'
}

# @description Unet a proxy for the terminal using tor
# @noargs
function termproxyX()
{ 
   unset http_proxy
   unset https_proxy
}

# @description Switch tor on and off (requires privoxy)
function torswitch()
{ 
   # copyright 2007 - 2010 Christopher Bratusek
   if [[ $EUID == 0 ]]; then
      case $1 in
      *on)
         if [[ $(grep forward-socks4a /etc/privoxy/config) == "" ]]; then
            echo "forward-socks4a / 127.0.0.1:9050 ." >>/etc/privoxy/config
         else
            sed -e 's/\# forward-socks4a/forward-socks4a/g' -i /etc/privoxy/config
            /etc/init.d/tor restart
            /etc/init.d/privoxy restart
         fi
         ;;
      *off)
         sed -e 's/forward-socks4a/\# forward-socks4a/g' -i /etc/privoxy/config
         /etc/init.d/tor restart
         /etc/init.d/privoxy restart
         ;;
      esac
   fi
}

###############################################################################
# Network information and IP address stuff
###############################################################################
# Scans a port, returns what's on it.
function port()
{ 
   lsof -i :"$1"
}

# Lists unique IPs currently connected to logged-in system & how many concurrent connections each IP has
function doscheck()
{ 
   "netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n"
}

# clear iptables rules safely
function clearIptables()
{ 
   iptables -P INPUT ACCEPT
   iptables -P FORWARD ACCEPT
   iptables -P OUTPUT ACCEPT
   iptables -F
   iptables -X
   iptables -L
}

# find an unused unprivileged TCP port
function findtcp()
{ 
   (
      netstat -atn | awk '{printf "%s\n%s\n", $4, $4}' | grep -oE '[0-9]*$'
      seq 32768 61000
   ) | sort -n | uniq -u | head -n 1
}

# Get just the HTTP headers from a web page (and its redirects)
function http_headers()
{ 
   curl -I -L $@
}

# Download a web page and show info on whattook time
function http_debug()
{ 
   curl $@ -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\n"
}

# usage: liveh [-i interface] [output-file] && firefox &
function liveh()
{ 
   tcpdump -lnnAs512 ${1-} tcp | sed ' s/.*GET /GET /;s/.*Host: /Host: /;s/.*POST /POST /;/[GPH][EOo][TSs]/!d;w '"${2-liveh.txt}"' ' >/dev/null
}

# geolocate a given IP address
function ip2loc()
{ 
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICountry\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
}

function ip2locall()
{ 
   # best if used through a proxy, as ip2loc's free usage only lets you search a maximum of 20 times per day
   # currently set on using a proxy through tor; if don't want that, just comment out the two 'export..' and 'unset...' lines
   export http_proxy='http://localhost:8118'
   export https_proxy='http://localhost:8118'
   echo ""
   echo "Country:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICountry\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Region (State, Province, Etc.):"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIRegion\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "City:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICity\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Latitude:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblILatitude\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Longitude:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblILongitude\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "ZIP Code:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIZIPCode\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Time Zone:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblITimeZone\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Net Speed:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblINetSpeed\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "ISP:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIISP\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Domain:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIDomain\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "IDD Code:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIIDDCode\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Area Code:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIAreaCode\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Weather Station:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIWeatherStation\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "MCC:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIMCC\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "MNC:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIMNC\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Mobile Brand:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIMobileBrand\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   unset http_proxy
   unset https_proxy
}

function ip2locate()
{ 
   # best if used through a proxy, as ip2loc's free usage only lets you search a maximum of 20 times per day
   # currently set on using a proxy through tor; if don't want that, just comment out the two 'export..' and 'unset...' lines
   export http_proxy='http://localhost:8118'
   export https_proxy='http://localhost:8118'
   echo ""
   echo "Country:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICountry\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Region (State, Province, Etc.):"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIRegion\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "City:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICity\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Latitude:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblILatitude\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   echo "Longitude:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblILongitude\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g'
   echo ""
   unset http_proxy
   unset https_proxy
}

# @description finds your current IP if your connected to the internet
function myip()
{ 
   lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | awk '{ print $4 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g'
}

# netinfo - shows network information for your system
function netinfo()
{ 
   echo "--------------- Network Information ---------------"
   /sbin/ip addr | awk /'inet addr/ {print $2}'
   /sbin/ip addr | awk /'Bcast/ {print $3}'
   /sbin/ip addr | awk /'inet addr/ {print $4}'
   /sbin/ip addr | awk /'HWaddr/ {print $4,$5}'
   myip=$(lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g')
   echo "${myip}"
   echo "---------------------------------------------------"
}

# check whether or not a port on your box is open
function portcheck()
{  for i in $@; do curl -s "deluge-torrent.org/test-port.php?port=$i" | sed '/^$/d;s/<br><br>/ /g'; done; }

# show Url information
# Usage:  url-info "ur"
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# Modified by Silviu Silaghi (http://docs.opensourcesolutions.ro) to handle
# more ip adresses on the domains on which this is available (eg google.com or yahoo.com)
# Last updated on Sep/06/2010
function url-info()
{ 
   doms=$@
   if [ $# -eq 0 ]; then
      echo -e "No domain given\nTry $0 domain.com domain2.org anyotherdomain.net"
   fi
   for i in $doms; do
      _ip=$(host $i | grep 'has address' | awk {'print $4'})
      if [ "$_ip" == "" ]; then
         echo -e "\nERROR: $i DNS error or not a valid domain\n"
         continue
      fi
      ip=$(echo ${_ip[*]} | tr " " "|")
      echo -e "\nInformation for domain: $i [ $ip ]\nQuerying individual IPs"
      for j in ${_ip[*]}; do
         echo -e "\n$j results:"
         whois $j | egrep -w 'OrgName:|City:|Country:|OriginAS:|NetRange:'
      done
   done
}

# cleanly list available wireless networks (using iwlist)
function wscan()
{ 
   iwlist wlan0 scan | sed -ne 's#^[[:space:]]*\(Quality=\|Encryption key:\|ESSID:\)#\1#p' -e 's#^[[:space:]]*\(Mode:.*\)$#\1\n#p'
}


###############################################################################
# Development
###############################################################################
# Decompiler for jar files using jad
function unjar()
{ 
   mkdir -p /tmp/unjar/$1
   unzip -d /tmp/unjar/$1 $1 *class 1>/dev/null && find /tmp/unjar/$1 -name *class -type f | xargs jad -ff -nl -nonlb -o -p -pi99 -space -stat
   rm -r /tmp/unjar/$1
}

# Computer the speed of two commands
function comp()
{  # compare the speed of two commands (loop $1 times)
   if [[ $# -ne 3 ]]; then return 1; fi
   echo -n 1
   time for ((i = 0; i < $1; i++)); do $2; done >/dev/null 2>&1
   echo -n 2
   time for ((i = 0; i < $1; i++)); do $3; done >/dev/null 2>&1
}

# Count opening and closing braces in a string
function countbraces()
{ 
   COUNT_OPENING=$(echo $1 | grep -o "(" | wc -l)
   COUNT_CLOSING=$(echo $1 | grep -o ")" | wc -l)
   echo Opening: $COUNT_OPENING
   echo Closing: $COUNT_CLOSING
}

# @description Remove files with sensitive data from a git commit
# https://stackoverflow.com/questions/872565/remove-sensitive-files-and-their-commits-from-git-history
function git_remove_leaks() {
   if [ $# -n 1 ]; then return 1; fi
   PATH_TO_YOUR_FILE_WITH_SENSITIVE_DATA=$1
   git filter-branch --force --index-filter \
   "git rm --cached --ignore-unmatch $PATH_TO_YOUR_FILE_WITH_SENSITIVE_DATA" \
   --prune-empty --tag-name-filter cat -- --all
   git push --force --verbose --dry-run
   git push --force
}
 
###############################################################################
# Hardware releated functions
###############################################################################
# Mount CIFS shares; pseudo-replacement for smbmount
# $1 = remote share name in form of //server/share
# $2 = local mount point
function cifsmount()
{ 
   if [ $# -lt 1 ] || [ $# -gt 2 ]; then
      echo "Mount CIFS shares; pseudo-replacement for smbmount"
      echo "cifsmount: [remote share name in form  //server/share] [local mount point]"
   else
      sudo mount -t cifs -o username=${USER},uid=${UID},gid=${GROUPS} $1 $2
   fi
}

# Remount a device
function remount()
{ 
   # copyright 2007 - 2010 Christopher Bratusek
   DEVICE=$1
   shift
   mount -oremount,$@ $DEVICE
}

# Mount Fat
function mount_fat()
{ 
   local _DEF_PATH="/media/tmp1"
   if [ -n "$2" ]; then
      sudo mount -t vfat -o rw,users,flush,umask=0000 "$1" "$2"
   else
      sudo mount -t vfat -o rw,users,flush,umask=0000 "$1" $_DEF_PATH
   fi
}

# Touchpad: to get information on touchpad
alias touchpad_id='xinput list | grep -i touchpad'

# Touchpad: to disable
# using 'touchpad_id', set the number for your touchpad (default is 12)
function touchpad_off()
{ 
   touchpad=12
   xinput set-prop $touchpad "Device Enabled" 0
}

# @description enable touchpad
# using 'touchpad_id', set the number for your touchpad (default is 12)
function touchpad_on()
{ 
   touchpad=12
   xinput set-prop $touchpad "Device Enabled" 1
}

# @section Gnome
# @description Functions related to gnome

# @description Enables all gnome-shell extensions
#
# * all in ~/.local/share/gnome-shell/extensions/
# * GPaste@gnome-shell-extensions.gnome.org
# * gnome-shell-extensions.gcampax.github.com
#
# Useful after a crash where all extensions are disabled
# @noargs
gnome-extensions-enable()
{ 
   localPath=~/.local/share/gnome-shell/extensions/
   for i in $localPath/*; do
      echo $(basename $i)
      gnome-extensions enable "$(basename $i)"
   done
   gnome-extensions enable GPaste@gnome-shell-extensions.gnome.org
   gnome-extensions enable gnome-shell-extensions.gcampax.github.com
}

# @section Zellij
# @description Helper functions for zellij

# @description List zellij layout files saved in the default layout directory, opens the selected layout file. Depends on: `tr`, `fd`, `sed`, `gum`, `grep` & `bash`
# Reference: https://zellij.dev/documentation/integration.html
# @noargs
# @set ZJ_SESSIONS string list of sessions
# @set NO_SESSION int number of sessions
function z-layout()
{ 
   set -euo pipefail
   ZJ_LAYOUT_DIR=$(zellij setup --check |
      grep "LAYOUT DIR" - |
      grep -o '".*"' - | tr -d '"')

   if [[ -d "${ZJ_LAYOUT_DIR}" ]]; then
      ZJ_LAYOUT="$(fd --type file . "${ZJ_LAYOUT_DIR}" |
         sed 's|.*/||' |
         gum choose ||
         exit)"
      zellij --layout "${ZJ_LAYOUT}"
   fi
}

# @description List current sessions, attach to a running session, or create a new one. Depends on gum & bash
# Reference: https://zellij.dev/documentation/integration.html
# @noargs
# @set ZJ_SESSIONS string list of sessions
# @set NO_SESSION int number of sessions
function z-sessions()
{ 
   ZJ_SESSIONS=$(zellij list-sessions)
   NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)

   if [ "${NO_SESSIONS}" -ge 2 ]; then
      zellij attach \
         "$(echo "${ZJ_SESSIONS}" | gum choose)"
   else
      zellij attach -c
   fi
}

# @section navi
# @description use navi for aliases

# @description returns best match using navi
# @arg $1 string search string
navialias()
{ 
   navi --query ":: $1" --best-match
}

# @description returns best match using navi
# @arg $1 string search string
navibestmatch()
{ 
   navi --query "$1" --best-match
}

# @section cryptsetup
# @description helper for cryptsetup

# @description open a luksdevice and mount it
# @arg $1 string luks file
# @arg $2 string name for the luks device
# @arg $3 string mountpoint where to mount
luksopen() {
   LUKS_SRC=$1
   LUKS_DEST=$2
   MOUNTPOINT=$3
   sudo cryptsetup luksOpen $LUKS_SRC $LUKS_DEST
   sudo mount /dev/mapper/$LUKS_DEST $MOUNTPOINT
}

# @description open a luksdevice and mount it
# @arg $1 string luks filename
luksopen_() {
   sudo cryptsetup luksOpen $LUKS_SRC $LUKS_DEST
   sudo mount /dev/mapper/$LUKS_DEST $MOUNTPOINT
}

# @description unmount and close a luksdevice
# @arg $1 string name for the luks device
# @arg $2 string mountpoint where to mount
luksclose() {
   LUKS_DEST=$1
   MOUNTPOINT=$2
   sudo umount $MOUNTPOINT
   sudo cryptsetup luksClose $LUKS_DEST
}

# @description unmount and close a luksdevice
# @arg $1 string name for the luks device
luksclose_() {
   sudo umount $MOUNTPOINT
   sudo cryptsetup luksClose $LUKS_DEST
}

# @section backup and restore configs
# @description helper to backup and restore some configs (mainly dconf for gnome)

# @description backup dconf
dconfbackup() {
   DCONF_BACKUP=$XDG_CONFIG_HOME/dconf/backup.dconf
   dconf dump / > $DCONF_BACKUP
   chezmoi add --encrypt $DCONF_BACKUP
}

# @description backup dconf
dconfrestore() {
   DCONF_BACKUP=$XDG_CONFIG_HOME/dconf/backup.dconf
   dconf load / < $DCONF_BACKUP
}

# @section nixos
# @description helper functions for nixos

# @description rebuild nixos with my config
nixsync () {
   export NIXOSWD=$HOME/Workspaces/papanito/nixos-configuration/
   export NIXOSDIR=/etc/nixos
   pushd $NIXOSWD
   # 1. sync config from working dir
   sudo rsync -rv $NIXOSWD --update --delete --exclude result $NIXOSDIR
   popd
}
# @description rebuild nixos with my config
nixreb () {
   nixsync
   # Source loale for us otherwise perl has issues
   source ~/.env-us.locale
   pushd $NIXOSWD
   if [[ -f "$NIXOSDIR/flake.nix" ]]; then
      sudo nixos-rebuild --flake '.#' switch 
   else
      sudo nixos-rebuild switch
   fi
}

# @description rebuild nixos with my config
nixrebu () {
   nixsync
   # Source loale for us otherwise perl has issues
   source ~/.env-us.locale
   pushd $NIXOSWD
   if [[ -f "$NIXOSDIR/flake.nix" ]]; then
      sudo nixos-rebuild --flake '.#' switch --upgrade
   else
      sudo nixos-rebuild switch --upgrade
   fi
}