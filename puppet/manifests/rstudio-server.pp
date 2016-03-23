include wget

$rstudioserver = 'rstudio-server-0.99.893-amd64.deb'
$urlrstudio = 'http://download2.rstudio.org/'

class install_opencv {
  package {[
    'libopencv-dev',
    'python-opencv',
    'ipython',
    'python-scipy'
  ]:
    ensure => present,
  }
}

# Update system for r install
class update_system {
  exec { 'apt_update':
    provider => shell,
    command  => 'apt-get update;',
  }
  ->
  package { [
    'software-properties-common','libapparmor1',
    'libdbd-mysql', 'libmysqlclient-dev','libssl-dev',
    'python-software-properties',
    'upstart', 'psmisc',
    'python', 'g++', 'whois','mc','libcairo2-dev',
    'default-jdk', 'gdebi-core', 'libcurl4-gnutls-dev',
    'libxml2-dev',
    'apache2']:
      ensure  => present,
  }
  ->
  exec { 'add-cran-repository':
    provider => shell,
    command  =>
    'add-apt-repository "deb http://cran.rstudio.com/bin/linux/ubuntu wily/";
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9;
  apt-get update;',
  }
  ->
  exec { 'upgrade-system':
    provider => shell,
    timeout => 2000, # On slow machines, this needs some time
    command  =>'apt-get -y upgrade; apt-get -y autoremove;',
  }
  ->
  # Install host additions
  # (following https://www.virtualbox.org/manual/ch04.html
  # this must be done after upgrading.
  package { 'dkms':
    ensure => present,
  }
}

class install_ipython_notebook {
  package {[
    'ipython-notebook']:
      ensure => present
  }
  ->
  # or you can assign them to a variable and use them in the resource
  file { '/usr/lib/systemd/system':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  ->
  file { "/usr/lib/systemd/system/ipython-notebook.service":
    owner => root,
    group => root,
    mode => 555,
    source => "puppet:///modules/ipython/ipython-notebook.service",
    #source => "puppet:///modules/wget/README.md",
    ensure => present,
  }
}


# Install r base and packages
class install_r {
  package { ['r-base', 'r-base-dev']:
    ensure  => present,
    require => Package['dkms'],
  }
  ->
  group { 'rstudio_users':
    ensure   => present,
  }
  ->
  user { 'litdata':
    ensure   => present,
    managehome => true
  }
  ->
  user { 'vagrant':
    # for R package installs, need:
      groups   => ['vagrant', 'rstudio_users', 'staff'],
  }
  ->
  exec {'install-r-packages':
    provider => shell,
    timeout  => 3000,
    command  => 'Rscript /vagrant/r-packages.R'
  }
}

# install rstudio and start service
class install_rstudio_server {
  # Download rstudio server
  wget::fetch {'rstudio-server-download':
    require  => Package['r-base'],
    timeout  => 0,
    destination => "${rstudioserver}",
    source  => "${urlrstudio}${rstudioserver}",
  }
  ->
  exec {'rstudio-server-install':
    provider => shell,
    command  => "gdebi -n ${rstudioserver}",
  }
  ->
  file { '/etc/rstudio/rsession.conf':
    ensure => file,
    mode => "a=r,u+w"
  }
  ->
  # Setting password during user creation does not work
  # Password is public; this is for local use only
  exec { 'serverpass':
    provider => shell,
    command => 'usermod -p `mkpasswd -H md5 litdata` litdata',
  }
}

# Make sure that both services are running
class check_services {
#  service {'rstudio-server':
#    ensure    => running,
#  }
  service {'ipython-notebook':
    ensure    => running,
  }
}

include update_system
include install_opencv
include install_r
include install_rstudio_server
include install_ipython_notebook
#include check_services
