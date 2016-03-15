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
sudo apt-get install -y apache2

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

mysql -uroot -proot --execute="
	GRANT ALL PRIVILEGES ON *.* TO '$keeper'@'localhost' IDENTIFIED BY '$keeperpass' WITH GRANT OPTION;
	GRANT SELECT ON *.* TO '$reader'@'localhost' IDENTIFIED BY '$readerpass';
"

rootMyCnf="/root/.my.cnf"

if [ -d /root ]; then
    echo "[client]" >> $rootMyCnf
    echo "user = root" >> $rootMyCnf
    echo "password = root" >> $rootMyCnf
    echo "host = 127.0.0.1" >> $rootMyCnf
fi

keeper="keeper"
keeperpass=""

reader="reader"
readerpass=""

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

# Clone the global d3 bindings if not exist in /var/www/html/
if [ -d /var/www/html/D3 ]; then
    pushd /var/www/html/D3
    git pull
    popd
else
    git clone http://github.com/bmschmidt/BookwormD3 /var/www/html/D3
fi;

# Enable CGI scripts for apache.

# Install bookworm

if [ ! -d bookwormDB ]; then
    git clone http://github.com/bookworm-project/bookwormDB;
    pushd bookwormDB;
    python setup.py install
    popd;
else
    # Grab the latest changes.
    cd bookwormDB
    git pull
    python setup.py install
fi

sudo a2enmod cgi
sudo service apache2 restart


# Create a test installation.
if [ -d federalist ]; then
    echo "federalist already exists"
else
    git clone http://github.com/bmschmidt/federalist;
    pushd federalist;

    # Manually make the bookworm.cnf file with these passwords.
    echo -e "[client]\ndatabase = federalist\nuser = $reader\npassword = $readerpass\n" > bookworm.cnf
    bookworm init;
    make;
    popd;    
fi;

# Set the server to refresh tables on reboot; waiting 100 seconds is really stupid, but gives MySQL a chance to warm up and
# mucking with the MySQL init.d files seems like a nightmare.
echo "@reboot root          sleep 100 && bookworm reload_memory --all" > /etc/cron.d/bookworm


echo "This machine has been set up as a Bookworm server. Confirm that it works by checking the website at http://localhost:8007/D3 to see if you get a bargraph."
