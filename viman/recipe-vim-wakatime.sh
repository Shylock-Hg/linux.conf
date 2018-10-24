#! /usr/bin/env sh

###############################################################################
# config vim-wakatime
###############################################################################
if curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/viman/.wakatime.cfg -o $HOME/.wakatime.cfg ; then
        echo "api_key=6507be58-712c-481d-bff3-477c6954afe7" >> $HOME/.wakatime.cfg
fi
