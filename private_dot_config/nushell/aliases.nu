#alias sudo = run0

# @description substitute some standard commands
alias grep = grep --color = auto # highlight matched pattern
alias egrep = grep -E
alias fgrep = fgrep –color = auto
alias root = su - # generic shortcut for switching to root user depending on system
alias real_location = readlink -f # get real location of file
alias reboot = sudo /sbin/reboot
alias shutdown = sudo shutdown -h now # proper restart
alias s = sudo
alias tac = tar -cvzf
alias tax = tar -xfvz
alias unpack = tar -xzvpf # uncompress a a Tar file
alias updatefont = fc-cache -v -f

# @section Computer cleanup
# @description cleanup helper functions
alias trashclean = rm -fr ~/.Trash

# @section System Info
# @description Hardware shortcuts and system info
#alias mountiso = sudo mount ${1} ${2} -t iso9660 -o ro,loop = /dev/loop0
alias scan = scanimage -L
alias dmidecode = sudo dmidecode --type 17 | more # check RAM sed and type in Linux
alias penv = printenv | grep

# @section Docker, Podman & k8s
# description Aliases for docker, kubernetes and related tech
alias pm = podman
alias pmprune = podman system prune --all
alias pmc = podman-compose
alias pmcup = podman-compose up
alias pmcdn = podman-compose down
alias pmcsta = podman-compose start
alias pmcsto = podman-compose stop
alias docker-compose = podman-compose
alias dm = docker-machine
alias dcup = docker-compose up -d --no-deps --force-recreate --build %a
#alias dterm = sudo docker exec -i -t $1 /bin/bash
#alias drm = docker rm $(docker container ls -aq)
alias drmi_m = docker images | grep months ago\|years ago | awk {print $3} | xargs docker rmi # remove docker images older than a month
alias dprune = docker system prune
alias ksh = navibestmatch Open shell to a pod in current context
alias kshc = navibestmatch Open shell to a pod in a specific context
alias klog = navibestmatch Print logs of a pod in current context
alias klogc = navibestmatch Print logs of a pod in s specific context

# @section Azure
# description command substitution azure-cli
alias az_subs = navibestmatch Get all Azure subscription names and ids

# @section terraform
# description command substitution terraform
alias tf = terraform
alias tfplan = terraform plan -no-color > generated.tfplan

# @section terminal multiplexer
# @description command substitution tmux,byobu, etc
alias zj = zellij
alias helix = hx
alias t = tomb
alias tm = tmux
#alias zellijj = zellij options --disable-mouse-mode
alias zm = zellij a main || zellij -s main

# @section ansible
# @description commande helpers for ansible

# @section chezmoi
# @description aliases for chezmoi
alias ca = chezmoi apply
alias cae = chezmoi apply --refresh-externals
alias cmadd = chezmoi add
alias chade = chezmoi add --emcrypt

# @section navi
# @description aliases for navi
alias k8sn = navi --query kubernetes
alias gln = navi --query glab
alias ghn = navi --query gh

# @section app aliases
# @description aliases for most used apps
alias linode = linode-cli

# @section misc tools
# @description command substitution for misc commands
alias script = script ~/session_`date +%Y%m%d%H%M`.txt # start shell session recording (typescript)
alias zshdocker = docker run -it zshusers/zsh
alias rcstate = restic -r $env.RESTIC_REPOSITORY snapshots
alias irssi = irssi --config=$env.XDG_CONFIG_HOME/irssi/config --home=$env.XDG_DATA_HOME/irssi
alias incognito =  fc -p; atuin history start disable
alias p = incognito
alias luo = luksopen_
alias luc = luksclose_
#alias firejail = firejail --net = tornet
alias cfs = cryfs
alias cum = cryfs-unmount

# @section nixos
# @description alias related to nixos
alias nix-shell = nix-shell --run zsh # https://stackoverflow.com/questions/33029821/configure-nix-shell-to-use-a-shell-other-than-bash
alias nix-search = nix --extra-experimental-features nix-command flakes search nixpkgs 
alias slowdown = s wondershaper -a wlo1 -d 8000
alias speedup = s wondershaper -ca wlo1
