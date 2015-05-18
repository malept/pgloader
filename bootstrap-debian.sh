#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ ! -f /etc/apt/sources.list.old ]
then
    sudo mv /etc/apt/sources.list /etc/apt/sources.list.old
    sudo cp /vagrant/conf/sources.list /etc/apt/sources.list
fi

if [ ! -f /etc/apt/preferences.d/sid.pref ]
then
    sudo cp /vagrant/conf/sid.pref /etc/apt/preferences.d/
fi

sudo apt-get update
sudo apt-get dist-upgrade -y

cat /vagrant/conf/bashrc.sh >> ~/.bashrc

sudo apt-get install -y postgresql-9.4 postgresql-contrib-9.4 \
                        postgresql-9.4-ip4r                   \
                        sbcl                                  \
                        git patch unzip                       \
                        devscripts pandoc                     \
                        libsqlite3-dev                        \
                        gnupg gnupg-agent freetds-dev

# SBCL and other build dependencies
sudo apt-get build-dep -y pgloader
sudo apt-get install -y -t unstable cl-mssql cl-uuid cl-trivial-utf-8

HBA=/etc/postgresql/9.4/main/pg_hba.conf
echo "local all all trust"              | sudo tee $HBA
echo "host  all all 127.0.0.1/32 trust" | sudo tee -a $HBA

sudo pg_ctlcluster 9.4 main reload
createuser -U postgres -sdR `whoami`
createdb -O `whoami` pgloader

make -C /vagrant pgloader test
