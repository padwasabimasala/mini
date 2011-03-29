#!/bin/bash
# Miningbased Bootstrapper
# send bug reports and feature requests to mthorley@globalbased.com
# 2010-04

# Bootstraps server and installs Mini fron svn into /var/www/apps
# Installs trunk by default. Pass in alternate svn url to override.

NFS_MNT_PRODUCTION=nfs1.miningbased.com:/mediaproduction
NFS_SOURCES_ROOT=/media/share/sources
NFS_CLIENTS_ROOT=/media/share/clients
SYSLOG_CONF=/etc/rsyslog.conf

function bigecho {
  echo
  echo -e "\E[34m# $@\E[0m"
  echo
}

function run {
  cmd="$@"
  echo -e "\E[36m$cmd\E[0m"
  eval $cmd
  if [[ $? != 0 ]]; then
    echo -e "\E[31merror\E[0m"
  fi
  echo
}

function install_prerequisites {
  bigecho installing installer prerequisites
  run apt-get update
  run apt-get install -y subversion build-essential vim git-core dstat htop mysql-client openssh-client openssh-server colordiff curl randomize-lines zsh iostat
}

function install_root_ssh_key {
  bigecho installing root ssh key
  if ! test -d /root/.ssh; then mkdir /root/.ssh; fi
  touch /root/.ssh/authorized_keys
  if test $(grep -c 'ssh-dss AAAAB3NzaC1kc3MAAACBAKzH+Re5WfG3uV' /root/.ssh/authorized_keys) -eq 0; then
    echo "ssh-dss AAAAB3NzaC1kc3MAAACBAKzH+Re5WfG3uVPYW0OcdzKhpLirWcR5h1+WJ6qDVxnIguhqroSuZAwT4RF3Ln7akxTr0QyOgLO8BQ+Pl9lwY/jB2K/Mq/7Z/s/G86mJQWw1xkml/ZKBRWi5i4oFNxSgcJhf7UZqSZbIbJ7KHCF+vC56kR+D73txZYJZlG1IwtC9AAAAFQC0ERHn0xt3baWPpdSaLhY9VaCTBQAAAIA0hcDr0rB7DwwHLsF2PPD/ipg8WVNvErX8jNGK9+AbQPoWpKSKHd1Sk/3QT/0FDRzE0EosVai03WcJOX2TI49pmyjvoxMoF7JU1HjxEUTXjo6kbrzpt7Cbml3Qoj35twmV1GgUpX9G4mmfbyyrzFiP1Nf64n5j4VyjoCfwE2GRTgAAAIAk7kMRfx6+znBQ8YIEM2Hxc72YFX4339rRQqAaFQd05Nlq13giTY9DPlK82Q2ZJvv9xI/LQMYyxNB0I0y/RzMMjKbiOmmSZ7cLfVRstdmgJrRXITW8tLcXo8RdDUTXdRXh3gK9WKvWxgr1EeGNpNbzS84eaGXay9MssQYENAWW0w==" >> /root/.ssh/authorized_keys
  fi
}
    
function install_vimrc {
  bigecho installing better vimrc
  vimrc="
    syntax on
    colorscheme elflord
    set tw=0
    set nowrap
    set ts=2
    set sw=4 
    set sts=2
    set expandtab
    set ai
    set smarttab
    set incsearch
    set ignorecase
    set hlsearch
  " 
  if [[ ! -f /root/.vimrc ]]; then echo "$vimrc" >> /root/.vimrc; fi
  if [[ ! -f /home/developer/.vimrc ]]; then echo "$vimrc" >> /home/developer/.vimrc; fi
}

function install_rsyslog_conf {
  RSYSLOG_CONF=/etc/rsyslog.d/100-mini.conf
  bigecho Installing $RSYSLOG_CONF
  if [ -e $RSYSLOG_CONF ];then
    bigecho Commenting out existing $RSYSLOG_CONF
    run 'cmtout=$(sed "s/^/#/g" $RSYSLOG_CONF); echo "$cmtout" > $RSYSLOG_CONF'
    echo "# Above conf commented out $(date) by bootstrap" >> $RSYSLOG_CONF
  fi
  cat >> $RSYSLOG_CONF <<EOF
:msg, contains, "[mini:" @admin.miningbased.com:514
:msg, contains, "[mini:" /var/log/mini.log
EOF
}

function install_ruby_etal { 
  bigecho apt-get installing ruby and related packages
  #   Note that rake is not installed here because it is installed by rails
  #   installing rake via apt can cause versioning issues and other headaches!
  run apt-get install -y ruby ruby1.8-dev libopenssl-ruby rdoc irb 
}

function install_rubygems {
  # check for ruby gems
  which gem > /dev/null
  if [[ $? != 0 ]]; then
    bigecho installing rubygems from source 
    #   use --no-format-executable option to ensure binary is called "gem"
    run mkdir -p /usr/local/src # may already exist
    run cd /usr/local/src 
    # rubygems 1.3.6 has a bug and does not correctly understand the -v option.
    run wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz 
    run tar zxf rubygems-1.3.7.tgz
    run cd rubygems-1.3.7; ruby setup.rb install --no-format-executable
  else
    echo -n 'rubygems is already installed at '
    which gem
  fi
}

function install_system_gems {
  bigecho gem installing system gems
  # System gems that need to work apart from bundler. All other gems go in the Gemfile
  run gem install bundler rake ZenTest capistrano --no-rdoc --no-ri
}

function install_and_setup_nfs {
  bigecho creating nfs mounts
  if [[ `aptitude search nfs-common |grep ^i -c` == 0 ]]; then
    run apt-get -y install nfs-common 
  fi
  echo
  if [[ `grep -c $NFS_MNT_PRODUCTION /etc/fstab` != 0 ]]; then
    echo "/etc/fstab contains entry matching '$NFS_MNT_PRODUCTION'"
    echo "Not creating mount for $NFS_MNT_PRODUCTION" 
  else
    run mkdir -p /media/share
    echo "$NFS_MNT_PRODUCTION /media/share nfs defaults 0 0" >> /etc/fstab
    run mount /media/share
  fi
}

function install_mini {
  bigecho Installing mini 
  mkdir -p /usr/share/mini/bundle
  MINI_DIR=/var/www/apps/mini
  mkdir -p $MINI_DIR
  cd $MINI_DIR
  git clone git://git.miningbased.com/mini mini.git
  ln -s $MINI_DIR/mini.git $MINI_DIR/current
  cd current
  ./bin/install
  cd /root
}

function install_mysql_server {
  bigecho installing mysql-server
  run export DEBIAN_FRONTEND=noninteractive
  run apt-get -q -y install mysql-server
  run sleep 2
  echo "Updating mysql password"
  run "#mysql -uroot -e ..."
  mysql -uroot -e <<EOSQL "UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root'; FLUSH PRIVILEGES;"
EOSQL
  if [[ $? != 0 ]]; then
    bigecho password update failed!
  fi
}

function install_mysql_databases {
  bigecho installing mysql databases
  for db in 'test' mini_production mini_stage mini_mthorley development integration_test; do
    run "mysql -uroot -proot -e 'create database $db'"
  done
}

function setup_mb_users {
  # Note users are installed with no password. 
  # To be able to login a user must install their ssh key to their home dir on the NFS
  for user in drnick:50000 spanky:50001 mrt:50002 blaine:50003; do
    USER=$(echo $user | cut -d':' -f1)
    USER_ID=$(echo $user | cut -d':' -f2)
    HOME_DIR=/media/share/users/$USER
    capture=$(id $USER 2>/dev/null)
    if test $? != 0; then
      if ! test -d $HOME_DIR; then mkdir -p $HOME_DIR; chown -R $USER $HOME_DIR; fi
      echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers
      useradd $USER -d $HOME_DIR -G sudo -G admin -u $USER_ID -s /bin/bash
    fi
  done
}

install_root_ssh_key
install_prerequisites 
install_rsyslog_conf
install_vimrc
install_ruby_etal  
install_rubygems 
install_system_gems 
install_and_setup_nfs 
install_mysql_server
install_mysql_databases
install_mini
setup_mb_users
