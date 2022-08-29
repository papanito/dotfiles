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
* [torswitch](#torswitch)
* [stopwatch](#stopwatch)
* [countdown](#countdown)
* [dic](#dic)
* [wordnet](#wordnet)
* [detectlanguage](#detectlanguage)
* [gi](#gi)
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

## Translation and Dictionary

Helper functions for checksumm calculation

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

### gi

Creates a .gitignore file from toptal's service.

#### Arguments

* **...** (string): comma separated list of languages

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

