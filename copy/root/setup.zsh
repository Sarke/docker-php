#!/bin/env zsh
source /root/antigen.zsh

antigen use oh-my-zsh

antigen bundle git
antigen bundle yii2
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting

antigen theme romkatv/powerlevel10k

antigen apply

source ~/.p10k.zsh
