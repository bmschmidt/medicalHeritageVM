import ConfigParser
import os
import MySQLdb
import sys
import argparse
import getpass
import subprocess
import logging

def determine_system_file(self):
    # The default, even if it doesn't exist, is this.
    systemFile = "/etc/my.cnf"
    # The last encountered in this list is the system file.
    for file in ["/etc/my.cnf","/etc/mysql/my.cnf"]:
        if os.path.exists(file):
            systemFile=file
    return systemFile

class Configfile:
    def __init__(self,usertype,stringArray,default=None):
        """
        Initialize with the location of the file. The last encountered file on the list is the one that will be used.
        """
        self.usertype = usertype
        self.location = None
        for string in stringArray:
            if os.path.exists(string):
                self.location=string
        if self.location is None:
            
            if default is None:
                raise IOError("No configuration file could be found and no default to create")
            else:
                self.location=default
                print "No configuration files at at any of [%s]. Creating a new configuration file for %s at %s" %(",".join(stringArray),self.usertype,self.location)
        else:
            print "Reading configuration file for %s from %s" %(self.usertype,self.location)
        
        self.config = ConfigParser.ConfigParser(allow_no_value=True)        
        self.config.read([self.location])

    def ensure_section(self,section):
        if not self.config.has_section(section):
            self.config.add_section(section)

    def change_client_password(self):
        """
        Changes the client password in the config file AND updates the MySQL server with the new password at the same time.
        """
        try:
            db = MySQLdb.connect(read_default_file="~/.my.cnf")
            db.cursor().execute("GRANT SELECT ON *.* to root@localhost")
        except MySQLdb.OperationalError, message:
            user = raw_input("Can't log in automatically: Please enter an *administrative* username for your mysql with grant privileges: ")
            password = raw_input("Now enter the password for that user: ")
            db = MySQLdb.connect(user=user,passwd=password)
            
        cur = db.cursor()
        self.ensure_section("client")
        try:
            user = self.config.get("client","user")
        except ConfigParser.NoOptionError:
            if self.usertype=="root":
                user = "root"
                self.config.set("client","user","root")
            else:
                user = raw_input("No username found for the user in the %s role.\nPlease enter the name for the %s user: " %(self.usertype,self.usertype))
                self.config.set("client","user",user)

        confirmation = 1
        new_password = 0

        while not confirmation == new_password:
            new_password = raw_input("Please enter a new password for user " + user + ", or hit enter to keep the current password: ")
            if new_password=="":
                new_password=self.config.get("client","password")
                break
            confirmation = raw_input("Please re-enter the new password for " + user + ": ")
        try:
            cur.execute("SET PASSWORD FOR '%s'@'localhost'=PASSWORD('%s')" % (user,new_password))
        except MySQLdb.OperationalError, message:	# handle trouble
            errorcode = message[0]
            if errorcode==1133:
                logging.info("creating a new %s user called %s" %(self.usertype,user))
                if self.usertype=="admin":
                    cur.execute("GRANT ALL ON *.* TO '%s'@'localhost' IDENTIFIED BY '%s' WITH GRANT OPTION" % (user,new_password))
                if self.usertype=="global":
                        cur.execute("GRANT SELECT ON *.* TO '%s'@'localhost' IDENTIFIED BY '%s'" % (user,new_password))
            else:
                raise
        self.config.set("client","password",new_password)

    def set_bookworm_options(self):
        """
        A number of specific MySQL changes to ensure fast queries on Bookworm.
        """
        self.ensure_section("mysqld")
        
        mysqldoptions = {"max_allowed_packet":"512M","sort_buffer_size":"8M","read_buffer_size":"4M","read_rnd_buffer_size":"8M","bulk_insert_buffer_size":"512M","myisam_sort_buffer_size":"512M","myisam_max_sort_file_size":"1500G","key_buffer_size":"1500M","query_cache_size":"32M","tmp_table_size":"1024M","max_heap_table_size":"1024M","character_set_server":"utf8","query_cache_type":"1","query_cache_limit":"2M"}

        for option in mysqldoptions.keys():
            if not self.config.has_option("mysqld",option):
                self.config.set("mysqld",option,mysqldoptions[option])
            else:
                if mysqldoptions[option] != self.config.get("mysqld",option):
                    choice = raw_input("Do you want to change the value for " + option + " from " + self.config.get("mysqld",option) + " to the bookworm-recommended " + mysqldoptions[option] + "? (y/N)")
                    if choice=="y":
                        self.config.set("mysqld",option,mysqldoptions[option])
                                       
    def write_out(self):
        self.config.write(open(self.location,"w"))

def change_root_password_if_necessary():
    """
    The root password should not be "root". So we change it if it is.
    """
    try:
        db = MySQLdb.connect(user="root",passwd="root",host="localhost")
        print "'root' is an insecure root password for MySQL: starting a process to change it. You can just re-enter 'root' if you want."
    except:
        try:
            db = MySQLdb.connect(user="root",passwd="",host="localhost")
            print "Your root MySQL password is blank; starting a process to change it. You can just hit return at the prompts to keep it blank if you want."
        except:
            print "Root mysql password is neither blank nor 'root', so it's up to you to change it."
            return

    root = Configfile("root",["/root/.my.cnf"],default="root_my.cnf")
    root.change_client_password()
    root.write_out()
    print """
    root .my.cnf file updated with password at %s; delete that file if you don't want the root password anywhere on your server.
    """ % root.location
  
def parse_args():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument("--sub","-s",help="run as subprocess")
    parser.add_argument("--force","-f",help="run as subprocess",action="store_true",default=False)
    parser.add_argument("users",nargs="+",choices=["admin","global","root"])
    return parser.parse_args()


def update_settings_for(name):
    """
    There are three roles: different things need to be changed for each.
    """
    if name=="root":
        change_root_password_if_necessary()
    if name=="admin":
        default_cnf_file_location = os.path.abspath(os.path.expanduser("~/.my.cnf"))
        admin = Configfile("admin",[default_cnf_file_location],default=default_cnf_file_location)
        admin.change_client_password()
        admin.write_out()
        
    if name=="global":
        system = Configfile("global",["/usr/etc/my.cnf","/etc/mysql/my.cnf","/etc/my.cnf","/etc/bookworm/my.cnf"],default="/etc/my.cnf")
        system.change_client_password()
        system.set_bookworm_options()
        system.write_out()
        

if __name__=="__main__":
    whoami = getpass.getuser()
    args = parse_args()
    names_to_parse = set(args.users)


    # Some names need to be run as root.
    privileged_names = names_to_parse.intersection(['global','root'])
    unprivileged_names = names_to_parse.intersection(['admin'])

    if len(privileged_names) > 0 and whoami != "root":
        # Some of these can only be automatically upgraded as root, probably.
        # We could try-catch this, I guess, but it's such a tiny set right now.
        print "Using sudo to process the users " + " and ".join(list(privileged_names)) + ". This may require a password." 
        subprocess.call(["sudo","python","fix_config.py"] + list(privileged_names))
        names_to_parse = unprivileged_names

    if "admin" in names_to_parse and whoami=="root":
        if not args.force:
            print "You're trying to update the admin user while logged in as root (using sudo?)" 
            print "That's confusing to me; if you're only going to run admin operations as root,"
            print "just set the root password."

    for name in names_to_parse:
        update_settings_for(name)
