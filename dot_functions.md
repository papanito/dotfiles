# .functions

Shared functions which are sourced when shell starts

## Overview

Shared functions which are sourced when shell starts
This is to be sourced not executed
# Shell-specifc functions

## Index

* [gi](#gi)
* [cmdfu](#cmdfu)
* [gnome-extensions-enable](#gnome-extensions-enable)
* [z-layout](#z-layout)
* [z-sessions](#z-sessions)

### gi

Creates a .gitignore file from toptal's service.

#### Arguments

* **...** (string): comma separated list of languages

## Commandlinefu

Commandlinefu.com and Shell-fu.org stuff

### cmdfu

Search commandlinefu.com from the command line # using the API

#### Arguments

* # @args $# string text to search

## Gnome

Random fun stuff

### gnome-extensions-enable

Enables all gnome-shell extensions

* all in ~/.local/share/gnome-shell/extensions/
* GPaste@gnome-shell-extensions.gnome.org
* gnome-shell-extensions.gcampax.github.com

Useful after a crash where all extensions are disabled

_Function has no arguments._

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

