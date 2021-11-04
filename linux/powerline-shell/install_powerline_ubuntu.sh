#!/bin/bash

#Installation des polices
cd /tmp
git clone https://github.com/powerline/fonts.git
./fonts/install.sh
rm -rf /tmp/fonts

wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
mkdir -p ~/.fonts/ && mv PowerlineSymbols.otf ~/.fonts/
fc-cache -vf ~/.fonts
mkdir -p ~/.config/fontconfig/conf.d/ && mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
sudo cp ~/.fonts/*.* /usr/share/fonts

#Intallation de powerline-shell
cd /opt
sudo -E git clone https://github.com/milkbikis/powerline-shell.git
sudo chown -R $USER:$USER /opt/powerline-shell
sudo chmod -R 775 /opt/powerline-shell
cd /opt/powerline-shell/
cp config.py.dist config.py
sed -i -e "s/    'username',/#    'username',/g" config.py
sed -i -e "s/    'hostname',/#    'hostname',/g" config.py

./install.py

ln -s /opt/powerline-shell/powerline-shell.py ~/powerline-shell.py

if grep -q '~/powerline-shell.py' "$HOME/.bashrc"; then
  echo "already installed in ${HOME}/.bashrc"
else
cat << EOF >> $HOME/.bashrc
    function _update_ps1() {
       PS1="\$(~/powerline-shell.py \$? 2> /dev/null)"
    }

    if [ "\$TERM" != "linux" ]; then
        PROMPT_COMMAND="_update_ps1; \$PROMPT_COMMAND"
    fi
EOF
fi
echo "#################################################";
echo "               Installation finished";
echo "      close your terminal and open a new one";
echo "#################################################";
