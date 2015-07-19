import ConfigParser
import os
import MySQLdb
import sys

class Configfile:
    def __init__(self,string):
        """
        Initialize with the location of the file
        """
        self.location=string
        if not os.path.exists(string):
            raise IOError("The configuration file " + os.path.abspath(os.path.expanduser(".my.cnf")) + " could not be read.\nAre you running this from the home directory of the primary Bookworm user?")
        self.config = ConfigParser.ConfigParser(allow_no_value=True)        
        self.config.read([string])

    def determine_system_file(self):
        systemFile = "/etc/mysql/my.cnf"
        if not os.path.exists(systemFile):
            systemFile = "/etc/my.cnf" #OS X location, for me.
            if not os.path.exists(systemFile):
                sys.stderr.write("Unable to find a working file, just writing to /etc/my.cnf\n")
                systemFile="/etc/mysql/my.cnf"
        return systemFile

    def ensure_mysqld(self):
        if not self.config.has_section("mysqld"):
            self.config.add_section("mysqld")

    def change_client_password(self):
        """
        Changes the client password in the config file AND updates the MySQL server with the new password at the same time.
        """
        db = MySQLdb.connect(read_default_file="~/.my.cnf")
        cur = db.cursor()
        user = self.config.get("client","user")
        confirmation = 1
        new_password = 0
        
        while not confirmation == new_password:
            new_password = raw_input("Please enter a new password for user " + user + ": ")
            confirmation = raw_input("Please re-enter the new password for " + user + ": ")
            
        cur.execute("SET PASSWORD FOR '%s'@'localhost'=PASSWORD('%s')" % (user,new_password))
        self.config.set("client","password",new_password)
        
    def set_bookworm_options(self):
        """
        A number of specific MySQL changes to ensure fast queries on Bookworm.
        """
        self.ensure_mysqld()
        
        mysqldoptions = {"max_allowed_packet":"512M","sort_buffer_size":"8M","read_buffer_size":"4M","read_rnd_buffer_size":"8M","bulk_insert_buffer_size":"512M","myisam_sort_buffer_size":"512M","myisam_max_sort_file_size":"1500G","key_buffer_size":"1500M","query_cache_size":"32M","tmp_table_size":"1024M","max_heap_table_size":"1024M","character_set_server":"utf8","query_cache_type":"1","query_cache_limit":"2M"}

        for option in mysqldoptions.keys():
            if not self.config.has_option("mysqld",option):
                self.config.set("mysqld",option,mysqldoptions[option])
            else:
                if mysqldoptions[option] != self.config.get("mysqld",option):
                    choice = raw_input("Do you want to change the value for " + option + " from " + self.config.get("mysqld",option) + " to " + mysqldoptions[option] + "? (y/N)")
                    if choice=="y":
                        self.config.set("mysqld",option,mysqldoptions[option])
                                       
    def write_out(self):
        self.config.write(open(self.location,"w"))

def change_root_password_if_necessary():
    """
    The root password should not be "root". So we change it if it is.
    """
    try:
        db = MySQLdb.connect(user="root",password="root")
    except:
        return

    cur = db.cursor()
    user = "root"
    confirmation = 1
    new_password = 0

    while not confirmation == new_password:
        new_password = raw_input("Please enter a new password for user " + user + ": ")
        confirmation = raw_input("Please re-enter the new password for " + user + ": ")

    cur.execute("SET PASSWORD FOR '%s'@'localhost'=PASSWORD('%s')" % (user,new_password))
    db.close()
    
if __name__=="__main__":
    print "By default, this installs some insecure passwords. Fixing those now..."
    change_root_password_if_necessary()

    # This sets the system password.
    system = Configfile("/etc/mysql/my.cnf")
    system.change_client_password()
    system.set_bookworm_options()
    system.write_out()
        
    # This sets the user one.

    if os.path.exists("/home/vagrant/.my.cnf"):
        user = Configfile("/home/vagrant/.my.cnf")
    else:
        location = raw_input("Where is the administrative user's .my.cnf file located? (Should be something like /home/vagrant/.my.cnf): ")
        user = Configfile(location)
    user.change_client_password()
    user.write_out()


