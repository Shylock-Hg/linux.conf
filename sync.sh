#! /usr/bin/env bash

while getopts 'o:h' args
do
	case $args in
		o)  #orientation
                        if [ $OPTARG = "backup" ]
                        then
                                #vim
                                cp ~/.vimrc                       ./
                                cp -r ~/.vim/                     ./
                                #shadowsocks
                                if [ ! -e ./.ss.d/ ]
                                then 
                                        mkdir ./.ss.d
                                fi
                                cp ~/.ss.pac                      ./.ss.d/
                                cp /etc/shadowsocks/.ss.conf.json ./.ss.d/
                                #conda
                                if [ ! -e .conda ]
                                then
                                        mkdir .conda
                                fi
                                source activate mltoolchain
                                conda env export -f               ./.conda/mltoolchain.yml
                                source deactivate
                                echo "Backup ok!"

                        elif [ $OPTARG = "reduct" ]
                        then
                                #vim
                                cp .vimrc              ~/
                                cp -r .vim/            ~/
                                #shadowsocks
                                cp .ss.d/.ss.pac       ~/
                                if [ -e /etc/shadowsocks/ ] 
                                then
                                        cp .ss.d/.ss.conf.json /etc/shadowsocks/
                                else
                                        echo "null /ect/shadowsocks!"
                                fi
                                echo "Reduct ok!"

                        else
                                echo "Unknown argument $OPTARG"
                        fi
			;;
                h)
                        echo "Usage: ./sync.sh -o <backup or reduct>!"
                        ;;
		?)
			echo "Unknown parameter!"
			;;
	esac
done

shift $(($OPTIND - 1))

