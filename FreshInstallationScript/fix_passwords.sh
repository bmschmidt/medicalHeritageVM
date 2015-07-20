#! /bin/bash


# Save the current directory.
mydir=$(pwd)

# At first, try to be the user "vagrant".
# Any other directories can just be added here.
if [ -d /home/vagrant ]; then
    pushd /home/vagrant
else
    read -p "Please enter the full filepath for the admin user (something like /home/username) :" adminname
    pushd adminname
fi;

# Update MySQL passwords.
sudo python $mydir/fix_config.py

# Switch back to the original directory.
popd;

echo "Please change the password: the current password is 'vagrant'. To change again, just type 'passwd'"

# Update system password.
passwd
