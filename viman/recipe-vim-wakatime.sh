#! /usr/bin/env sh

###############################################################################
# config vim-wakatime
###############################################################################
curl -s https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/viman/.wakatime.cfg -o $HOEM/.wakatime.cfg
echo "api_key=$WAKATIME_KEY" >> $HOME/.wakatime.cfg
