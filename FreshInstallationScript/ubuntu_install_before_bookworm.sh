sudo mysql_secure_installation


echo
echo "Setting up MySQL User Accounts"
echo
echo "Type a name for a MySQL User with all writing priveleges, then hit [Enter]:"
read keeper

pass_not_set=true
while [ $pass_not_set == true ]; do	
	echo
	echo "Type a password for [$keeper], then hit [Enter]:"
	read -s keeperpass
	echo
	echo "Retype the password for [$keeper], then hit [Enter]:"
	read -s keeperpass2
	echo
	if [ $keeperpass != $keeperpass2 ]
		then
			echo "The passwords typed were not the same."
	fi
	if [ $keeperpass == $keeperpass2 ]
		then
			pass_not_set=false
	fi
done


echo
echo "Type a name for a MySQL User with read only priveleges, then hit [Enter]:"
read reader

pass_not_set=true
while [ $pass_not_set == true ]; do	
	echo
	echo "Type a password for [$reader], then hit [Enter]:"
	read -s readerpass
	echo
	echo "Retype the passwrod for [$reader], then hit [Enter]:"
	read -s readerpass2
	echo
	if [ $readerpass != $readerpass2 ]
		then
			echo "The passwords typed were not the same."
	fi
	if [ $readerpass == $readerpass2 ]
		then
			pass_not_set=false
	fi
done

echo
echo "Log into MySQL with your original root password:"

mysql -u root -p --execute="CREATE USER '$keeper'@'localhost' IDENTIFIED BY '$keeperpass'; \
	GRANT ALL PRIVILEGES ON *.* TO '$keeper'@'localhost' WITH GRANT OPTION; \
	CREATE USER '$keeper'@'%' IDENTIFIED BY '$keeperpass'; \
	GRANT ALL PRIVILEGES ON *.* TO '$keeper'@'%' WITH GRANT OPTION; \
	CREATE USER 'admin'@'localhost'; \
	GRANT RELOAD,PROCESS ON *.* TO 'admin'@'localhost'; \
	CREATE USER '$reader'@'localhost' IDENTIFIED BY '$readerpass'; \
	GRANT SELECT ON *.* TO '$reader'@'localhost' WITH GRANT OPTION; \
	CREATE USER '$reader'@'%' IDENTIFIED BY '$readerpass'; \
	GRANT SELECT ON *.* TO '$reader'@'%' WITH GRANT OPTION;"


#
echo
echo "Now to create the MySQL .my.cnf file"
echo



# ****************************************************


cd ~
echo " " >> .my.cnf
echo "#" >> .my.cnf
echo "# The MySQL Database Server Configuration File" >> .my.cnf
echo "#" >> .my.cnf
echo " " >> .my.cnf
echo "[client]" >> .my.cnf
echo "user = $keeper" >> .my.cnf
echo "password = $keeperpass" >> .my.cnf
echo " " >> .my.cnf


# ****************************************************



#
# Setup git account
#

sudo apt-get install -y git

echo
echo "Type your GitHub username, then hit [Enter]:"
read gituser
echo "Type your GitHub email, then hit [Enter]:"
read gitemail

git config --global user.name "$gituser"
git config --global user.email "$gitemail"

#
echo
echo "Create ssh key (use rsa_id as the filename)"

cd ~/.ssh && ssh-keygen

#
echo
echo "Copy the rsa public key:\n\n"
cat id_rsa.pub
echo
echo "Go to your Github accout and paste it under Settings>SSH keys"

#

git_ssh_not_updated=true
while [ $git_ssh_not_updated == true ]; do	
	echo
	echo "When you have done so, type yes, then press [Enter]:"
	read ssh_updated
	if [ $ssh_updated == "yes" ]; then
		git_ssh_not_updated=false
	fi
done

# print out instructions for the user
echo
echo "Now you may download the git file"
echo "Here is a list of commands:"
echo
echo "    >  cd ~"
echo
echo "    >  git clone http://github.com:bmschmidt/federalist.git"
echo
echo "    >  vim federalist/federalist/scripts/makeConfiguration.py"
echo "    Now run the bookworm"
echo
echo "    >  cd federalist"
echo "    >  make federalistdatabase"
