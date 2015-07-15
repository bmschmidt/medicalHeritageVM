#!/bin/bash

#
echo
echo "Set up the basics"
echo

# No need to waste the time here?
#sudo apt-get update -y
#sudo apt-get upgrade -y
#sudo apt-get dist-upgrade -y
sudo apt-get install -y gcc
sudo apt-get install -y build-essential python-dev libmysqlclient-dev
sudo apt-get install -y parallel

# LAMP Server components

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install -y mysql-server-5.6 mysql-client-5.6
sudo apt-get install -y apache2 apache2-bin apache2-data apache2-mpm-prefork libapache2-mod-php5 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap php5-cli php5-common php5-json php5-mysql php5-readline ssl-cert

sudo apt-get install -y git

#
echo
echo "Install Python and Extensions"
echo

sudo apt-get install -y python-dev
sudo apt-get install -y python-pip
sudo pip install regex
sudo pip install nltk
sudo pip install numpy
sudo pip install pandas
sudo pip install mysql-python
sudo pip install python-dateutil


# At this point, mysql's root password is just 'root'

keeper="keeper"
keeperpass=""

reader="reader"
readerpass=""

mysql -uroot -proot --execute="
	GRANT ALL PRIVILEGES ON *.* TO '$keeper'@'localhost' IDENTIFIED BY '$keeperpass' WITH GRANT OPTION;
	GRANT SELECT ON *.* TO '$reader'@'localhost' IDENTIFIED BY '$readerpass';
"


# No longer changing to `~/`, because as root that isn't the user's home directory and this script should be run as root.
# So now these commands must be run from inside ~, which seems reasonable?

localMyCnf=".my.cnf"

if [ ! -f $localMyCnf ]; then
    echo "[client]" >> $localMyCnf
    echo "user = $keeper" >> $localMyCnf
    echo "password = $keeperpass" >> $localMyCnf
    echo "host = 127.0.0.1" >> $localMyCnf
fi

# Give root that information too if we happen to be root; otherwise this won't do anything.
cp .my.cnf ~/.my.cnf


# The core my.cnf file determines how the web server logs in.

globalMyCnf="/etc/mysql/my.cnf"

if [ ! -f $globalMyCnf ]; then
    echo "[client]" >> $globalMyCnf
    echo "user = $reader" >> $globalMyCnf
    echo "password = $readerpass" >> $globalMyCnf
    echo "host = 127.0.0.1" >> $globalMyCnf
else
    # Add the lines into the existing client block if the file exists.
    perl -pi -e "s/(\[client\])/\$1\nuser = $reader\npassword = $readerpass\nhost = 127.0.0.1\n/gi;" /etc/mysql/my.cnf
fi

# Set up the API and webserver

# Clone the API if not exists, else pull;
if [ -d /usr/lib/cgi-bin/bookworm ]; then
    pushd /usr/lib/cgi-bin
    git pull
    popd;
else
    git clone http://github.com/Bookworm-Project/BookwormAPI /usr/lib/cgi-bin/;
fi;

# Clone the global d3 bindings if not exist in /var/www/html/
if [ -d /var/www/html/D3 ]; then
    pushd /var/www/html/D3
    git pull
    popd
else
    git clone http://github.com/bmschmidt/BookwormD3 /var/www/html/D3
fi;

# Enable CGI scripts for apache.
sudo a2enmod cgi
sudo service apache2 restart

# create a test bookworm

if [ -d federalist ]; then
    pushd federalist/federalist;
    python OneClick.py reloadMemory;
    popd;
else
    git clone http://github.com/bmschmidt/federalist;
    pushd federalist;
    make federalist;
    # Manually make the bookworm.cnf file with these passwords.
    echo -e "[client]\ndatabase = federalist\nuser = $reader\npassword = $readerpass\n" > federalist/bookworm.cnf
    make;
    popd;
fi;

echo "This machine has been set up as a Bookworm server. Confirm that it works by checking the website at http://localhost:8007/D3 to see if you get a bargraph."
