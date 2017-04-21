#!/bin/bash

# Install Docker

#config dns for svi
sed -i '/nameserver.*/d' /etc/resolv.conf
echo "nameserver 202.96.134.133"  >> /etc/resolv.conf


#check network
if ! ping -c1 -W3 dockerproject.org >&/dev/null; then
    echo "Network error!"
    exit 3
fi

#backup apt source file, and use new source download
cp /etc/apt/sources.list /etc/apt/sources.list-bak

(
cat <<EOF
deb http://mirrors.aliyun.com/ubuntu/ yakkety main restricted
deb http://mirrors.aliyun.com/ubuntu/ yakkety-updates main restricted
deb http://mirrors.aliyun.com/ubuntu/ yakkety universe
deb http://mirrors.aliyun.com/ubuntu/ yakkety-updates universe
deb http://mirrors.aliyun.com/ubuntu/ yakkety multiverse
deb http://mirrors.aliyun.com/ubuntu/ yakkety-updates multiverse
deb http://mirrors.aliyun.com/ubuntu/ yakkety-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ yakkety-security main restricted
deb http://mirrors.aliyun.com/ubuntu/ yakkety-security universe
deb http://mirrors.aliyun.com/ubuntu/ yakkety-security multiverse
# deb-src https://apt.dockerproject.org/repo/ ubuntu-yakkety main
# deb-src https://apt.dockerproject.org/repo/ ubuntu-yakkety main
EOF
) >/etc/apt/sources.list


#install add-apt-repository
sudo apt-get -y install \
  python-software-properties \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  curl


#loop to install docker app
while :
do
    #1. Set up the repository
    #Set up the Docker CE repository on Ubuntu. The lsb_release -cs sub-command prints the name of your Ubuntu version, like xenial or trusty.
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    sudo add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
           $(lsb_release -cs) \
           stable"

    sudo apt-get update

    #2. Get Docker CE
    #Install the latest version of Docker CE on Ubuntu:
    sudo apt-get -y install docker-ce <<EOF
N
EOF
    systemctl enable docker

    #3. Test your Docker CE installation
    sudo docker run hello-world

    if [ $? -ne 0 ]
    then
        echo "Failed to run container,retry..."
        continue
    else
        echo "Success to run container"
    fi

    #4. Check result
    which docker

    if [ $? -ne 0 ]
    then
        echo "Install docker failed,retry..."
        continue
    else
        echo "Install docker successful!"
        break
    fi
done

#restore backup file
mv /etc/apt/sources.list-bak /etc/apt/sources.list

exit $?

echo "===================== done! ================================"

