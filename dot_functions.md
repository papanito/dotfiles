# .functions

Shared functions which are sourced when shell starts

## Overview

This is to be sourced not executed

## Index

* [start](#start)
* [stop](#stop)
* [status](#status)
* [sstatus](#sstatus)
* [senable](#senable)
* [services](#services)
* [irssi_client_cert](#irssi_client_cert)
* [cds](#cds)
* [empty](#empty)
* [lcfirst](#lcfirst)
* [ltrim](#ltrim)
* [rtrim](#rtrim)
* [strim](#strim)
* [strtolower](#strtolower)
* [strtoupper](#strtoupper)
* [trim](#trim)
* [find_execute](#find_execute)
* [torswitch](#torswitch)
* [stopwatch](#stopwatch)
* [countdown](#countdown)
* [random](#random)
* [currency_convert](#currency_convert)
* [dic](#dic)
* [wordnet](#wordnet)
* [detectlanguage](#detectlanguage)
* [activate-venv](#activate-venv)
* [gi](#gi)
* [fbr](#fbr)
* [fco](#fco)
* [fbd](#fbd)
* [cmdfu](#cmdfu)
* [fuman](#fuman)
* [gnome-extensions-enable](#gnome-extensions-enable)
* [errormsg](#errormsg)
* [z-layout](#z-layout)
* [z-sessions](#z-sessions)

## Systemd service

Funcions specific to zsh, bash or other shells

### start

start a service

#### Arguments

* **$1** (string): name of service

### stop

stop a service

#### Arguments

* **$1** (string): name of service

### status

query status of a service

#### Arguments

* **$1** (string): name of service

### sstatus

query status of a service

#### Arguments

* **$1** (string): name of service

### senable

enable a service

#### Arguments

* **$1** (string): name of service

### services

_Function has no arguments._

## IRC

irc helper functions

### irssi_client_cert

_Function has no arguments._

## Directories/Folders

Helper functions to deal with directories

### cds

Change directory and list files

#### Arguments

* **$1** (string): directory name

### empty

Show empty files in the directed directory
copyright 2007 - 2010 Christopher Bratusek

#### Arguments

* **$1** (string): path to check

## string manipulation

Functions to manipulate strings

### lcfirst

Convert the first letter into lowercase letters

#### Arguments

* **$1** (string): string to change

#### Exit codes

* string whhere first letter is lowercase

### ltrim

Remove whitespace at the beginning of a string

#### Example

```bash
echo "   That is a sentinece" | rtrim
```

#### Arguments

* **$1** (string): string from which to remove whitespaced

#### Exit codes

* string w/o whitespaces at the beginning of the string

### rtrim

Remove whitespace at the end of a string

#### Example

```bash
echo "That is a sentinece " | rtrim
```

#### Arguments

* **$1** (string): string from which to remove whitespaced

#### Exit codes

* string w/o whitespaces at the end

### strim

Cut a string after X chars and append three points

#### Example

```bash
strim averylongstring 2
```

#### Arguments

* **$1** (string): string to shortened/cut
* **$2** (int): length of the string

#### Exit codes

* shortened string

### strtolower

Convert all alphabetic characters to lowercase

#### Arguments

* **$1** (string): string to convert

#### Exit codes

* converted string

### strtoupper

Convert all alphabetic characters converted to uppercase

#### Arguments

* **$1** (string): string to convert

#### Exit codes

* converted string

### trim

Remove whitespace at the beginning and end of a string

#### Example

```bash
echo " That is a sentinece " | trim
```

#### Arguments

* **$1** (string): string to convert

#### Exit codes

* converted string

## find (a) file(s)

Functions and aliases to find files

### find_execute

fing files  with pattern $1 in name and Execute $2 on it

#### Arguments

* **$1** (string): search pattern
* **$2** (string): command to execute on found files

## Proxy and Anomymization

Helper functions for proxy and tor

### torswitch

Switch tor on and off (requires privoxy)

## Stopwatch and Countdown Timer

Helper functions

### stopwatch

simple stopwatch for terminal
copyright 2007 - 2010 Christopher Bratusek

### countdown

countdown clock

#### Arguments

* **$1** (int): seconds to count

## Checksum

Helper functions for checksumm calculation

### random

random number (out of whatever you input)
copyright 2007 - 2010 Christopher Bratusek

#### Arguments

* **$1** (string): [optional] `-L` or `-r` 
* **$2** (int): value

### currency_convert

convert currencies
for currency shorthand: http://www.xe.com/currency/

#### Arguments

* **$1** (int): value to convert
* **$2** (string): currency shorthand to convert from
* **$3** (string): currency shorthand to convert to

## Translation and Dictionary

helper functions for word definitions and translations

### dic

Lookup a word with dict.org

#### Arguments

* $# string word to lookup

### wordnet

Lookup a word with dict.org in WordNet

#### Arguments

* **$1** (string): word to lookup

### detectlanguage

detect language of a string

## python

Activating python virtual environments
Keep python virtual environments in a central place in ~/.venv. To activate one of the environments,this function can be used

### activate-venv

Activating python virtual environments
Keep python virtual environments in a central place in ~/.venv. To activate one of the environments,this function can be used

## git and source control

Creates a .gitignore file from toptal's service.

### gi

Creates a .gitignore file from toptal's service.

#### Arguments

* **...** (string): comma separated list of languages

### fbr

checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches

### fco

checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD

### fbd

delete git branches, with log preview

## Commandlinefu

Commandlinefu.com and Shell-fu.org stuff

### cmdfu

Search commandlinefu.com from the command line # using the API

#### Arguments

* $# string text to search

### fuman

fuman, an alternative to the 'man' command that shows commandlinefu.com examples

#### Arguments

* **$1** (string): command

## Gnome

Random fun stuff

### gnome-extensions-enable

Enables all gnome-shell extensions

* all in ~/.local/share/gnome-shell/extensions/
* GPaste@gnome-shell-extensions.gnome.org
* gnome-shell-extensions.gcampax.github.com

Useful after a crash where all extensions are disabled

_Function has no arguments._

### errormsg

#### Arguments

* **$1** (string): error message to show

## Zellij

Helper functions for zellij

### z-layout

List zellij layout files saved in the default layout directory, opens the selected layout file. Depends on: `tr`, `fd`, `sed`, `gum`, `grep` & `bash`
Reference: https://zellij.dev/documentation/integration.html

_Function has no arguments._

#### Variables set

* **ZJ_SESSIONS** (string): list of sessions
* **NO_SESSION** (int): number of sessions

### z-sessions

List current sessions, attach to a running session, or create a new one. Depends on gum & bash
Reference: https://zellij.dev/documentation/integration.html

_Function has no arguments._

#### Variables set

* **ZJ_SESSIONS** (string): list of sessions
* **NO_SESSION** (int): number of sessions

