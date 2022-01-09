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

# antigen bug (https://github.com/zsh-users/antigen/issues/698) breaks oh-my-zsh completions, need to be called manually
#source /root/.antigen/bundles/robbyrussell/oh-my-zsh/plugins/yii2/yii2.plugin.zsh
# commented out in antigen.zsh instead
