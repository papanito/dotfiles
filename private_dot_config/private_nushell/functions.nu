def reload [] {
    source-env $nu.env-path
    print "Nushell environment reloaded!"
 }

 # @description rebuild nixos with my config
def nixsync [] {
    let NIXOSWD = $"($env.HOME)/Workspaces/papanito/nixos-configuration/"
    let NIXOSDIR = "/etc/nixos"
    cd $NIXOSWD
    # 1. sync config from working dir
    sudo rsync -rv $NIXOSWD --update --delete --exclude result $NIXOSDIR
    dirs drop
}

def nixreb [
    hostname?: string
    -u
    -i
    -s
    -r
    -v
] {
    let NIXOSWD = $"($env.HOME)/Workspaces/papanito/nixos-configuration/"
    let NIXOSDIR = "/etc/nixos"
    let UPGRADE = ""
    if $u {
        let UPGRADE = "--upgrade"
    }

    let IMPURE = ""
    if $u {
        let IMPURE = "--impure"
        $env.NIXPKGS_ALLOW_INSECURE = 1
    }

    let SWITCH = ""
    if $s {
        let SWITCH = "--switch"
    }

    let $REMOTE = ""
    if $r {
        let SWITCH = $"--target-host ($hostname)"
    }

    let $VERBOSE = ""
    if $v {
        let VERBOSE = "--show-trace"
    }

    cd $NIXOSWD
    # sync config from working dir
    sudo rsync -rv $NIXOSWD --update --delete --exclude result $NIXOSDIR
    # Source loale for us otherwise perl has issues
    $env.LANG_ALL = "en_US.UTF-8"
    cd $NIXOSWD
    if ( "($NIXOSDIR)/flake.nix" | path exists) {
        sudo nixos-rebuild $SWITCH --flake '.#$HOSTNAME' $UPGRADE $REMOTE $IMPURE $VERBOSE
    } else {
        sudo nixos-rebuild $SWITCH $UPGRADE $IMPURE $VERBOSE
    }
    dirs drop
}
