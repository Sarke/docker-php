#!/bin/env zsh

autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

source ~/.zsh_plugins.sh

source ~/.p10k.zsh
