#!/bin/bash
# This script will install vulnerable applications using Docker so that we can learn how to hack web applications
# Version 1.0
# Youtube: https://www.youtube.com/c/beauknowstechstuff
# Twitter: @BeauKnowsTech
# Only been tested in Kali

# check if root cuz not supposed to be root
if [ "$EUID" -eq 0 ]
  then echo "This script is not meant to ran with sudo. It will ask you for your password if needed"
  exit
fi

sudo apt update

# Check and make sure git is installed
echo -e "\nChecking to see if git is instlld already"
if git --version ; then
    echo -e "Git is already installed"
    else
    echo -e "Doesn't look like git is installed, lets fix that"
    sudo apt install git -y
fi

## check if running on wsl and if docker is installed 
echo -e "\nChecking to see if running on WSL \n"
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    echo -e "Running on WSL Windows 10 \n"
    echo -e "Sidenote, you will have to install burp suite manually if running on WSL. Alternatively, you could install it on windows instead of in kali\n"
    if docker > /dev/null 2>&1 ; then
        echo -e "Docker is running \n"
    else
        echo "Docker is either not running or not installed."
        echo "At the time of writing, Docker recommends that if you are running WSL to install Docker Desktop"
        echo "Docker Desktop has a built in WSL integration. I'd go with WSL2"
        echo "See https://docs.docker.com/docker-for-windows/wsl/ for details."
        exit
    fi
else
    echo "Not Running on WSL, lets keep going"
    if docker > /dev/null 2>&1 ; then
    echo -e "Docker is running \n"
    else
    echo -e "Installing docker\n"
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt remove docker docker-engine docker.io
    sudo apt install -y docker-ce
    sudo groupadd docker
    sudo usermod -aG docker $USER
    echo -e "\e[31mDocker is not installed, after it installs you will need to restart the script\e[0m"
    echo -e "\e[31mby running ./WebApp-Lab-Setup.sh again\e[0m"
    newgrp docker
    fi
fi

# install zsh + OhMyzsh
echo -e "Installing ZSH and ohmyzsh, if not already installed \n"

if zsh --version ; then
    echo -e "Looks like ZSH is already installed. Very nice"
    else
    echo -e "ZSH not detected, installing ZSH and ohmyzsh"
    sudo apt install zsh -y
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # set zsh as default shell
    echo "Attempting to set zsh as default shell"
    chsh -s $(which zsh)
fi


# Install vulnerable docker containers
echo -e "\nInstalling vulnerable docker containers Juice Shop, Webgoat/WebWolf, DVWA"
tz=$(cat /etc/timezone)
docker run --name juice-shop --restart unless-stopped -d -p 3000:3000 bkimminich/juice-shop
docker run --name goatandwolf --restart unless-stopped -d -p 8080:8080 -p 9090:9090 -e TZ=$tz webgoat/goatandwolf
docker run --name web-dvwa --restart unless-stopped -d -p 80:80 vulnerables/web-dvwa

echo -e "\nHere are the running docker containers\n"
docker ps

#todo
# install any tools we still need

