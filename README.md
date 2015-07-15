

This provides a self-contained virtual environment for deploying a Bookworm server hosting a MySQL database, the Bookworm API over a LAMP stack, and a set of websites for exploration
including a version of the RStudio server.

The base installation has been forked from Andrew Goldstone's [Course materials for Literary Data](https://github.com/agoldst/litdata-vagrant); most of the text of the README that follows is a modified version of the README from his course.



# Installation

Requirements: this is meant to run on almost any system. However, you will need a substantial amount of RAM (4 GB) and disk space (5 GB).

1. Install [Vagrant](https://www.vagrantup.com/downloads).
2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
3. Download [this repository as a zip archive](https://github.com/bschmidt/litdata-vagrant/archive/master.zip) and unzip it. Note the folder you unzip it into.
4. Open a terminal (Windows calls this a "Command Window") and change to the folder from the last step. (Use the `cd` command.) If you downloaded it to your "downloads" folder, for example, you would type `cd /Home/$username/Downloads/litdata-vagrant-master.zip`, replacing `$username` with your own username on the system. You're in the right place if, when you enter `ls` and press Return, you see `Vagrantfile` among those listed.
5. Enter the command: `vagrant box add ubuntu/trusty64` and press Return. 
6. Enter the command: `vagrant up` and press Return. Now begins a long process of downloading and installing software. This will require a large amount of disk space and time to complete. You will know it is finished when you get a new command prompt (and hopefully no error messages).


# Testing

1. Open your web browser and visit `http://localhost:8007`. You should see a bar graph giving the names of the authors of the Federalist papers: type "upon" into the box and see if the bars move.
1. Open your web browser and visit `http://localhost:8787`. You should see an RStudio login screen. Enter username `vagrant` and password `vagrant` and log in. You should now see a three-paned RStudio window.
1. Enter `vagrant halt` and press Return.

# Starting and stopping the virtual machine

Before you can use RStudio in your web browser, you have to start the virtual machine. That is what `vagrant up` does. (It's much faster after the first time, because there's no new software to install.) Once you are done working, you will want to reclaim the (large) amount of RAM required to run all this software locally. That is the purpose of the command `vagrant halt`.

# Saving your work

When you are working in RStudio Server, your files live on the virtual machine's virtual hard drive. How do you get those files off the virtual machine and back to your regular hard drive so you can print them, e-mail them, back them up, etc.? The answer is that a special folder is *shared* between the virtual machine and your real hard drive. This is `/vagrant`. Any file you save there on the virtual machine will appear in the folder where you saved the `Vagrantfile`. The same process works in reverse.

Because `/vagrant` itself is cluttered with the files for running the vritual machine (`Vagrantfile`, etc.), you'll find it convenient to create a subfolder of this directory and use *that* as your usual working directory.

(The following note is from Andrew Goldstone): This configuration is based on a repository by [Dieter Menne](https://bitbucket.org/dmenne/rstudio-shiny-server-on-ubuntu). I have also made use of work by [Lincoln Mullen](https://github.com/lmullen/vagrant-r-dev/).

# What's installed and how to modify it

In case anyone wants to fork this repository for their own courses or other purposes, here's a little more detail about what's installed:

## The virtual machine

The machine is the `ubuntu/trusty64` box [on Atlas](https://atlas.hashicorp.com/ubuntu/boxes/trusty64), i.e. Ubuntu 14.04 (Trusty Tahr) for AMD64 architectures under the Virtualbox provider. I borrowed this choice from the repositories cited above. 

The machine is configured with 2GB of RAM, which is fine for most pedagogical purposes. Some students will need to reduce this allocation before the VM can fit in their machine's physical RAM. Conversely, the matrices and arrays required for topic-modeling with MALLET consume a lot of RAM and may require a larger allocation. Edit the line in [Vagrantfile](Vagrantfile#L11) reading

````
      v.memory = 2048
````

to change the allocation. The number is in megabytes. Use `vagrant reload` for the configuration to take effect.

## User accounts

The machine configuration is governed by a Puppet manifest, [rstudio-server.pp](puppet/manifests/rstudio-server.pp). What I know about Puppet could fit on a postage stamp, so I am sure this isn't elegantly done, but it seems to do the job.

The puppet script is creates a single user, `vagrant`, which is also the RStudio Server user. I couldn't get things working when the two were different. I don't see obvious security concerns if this machine is running locally on your own machine, but don't deploy this image to the cloud (or to unsecured lab machines) without some better security configuration, since the username and password are here in the clear. 

## Software

 It installs (not exactly in this order):

1. The latest available R

2. The latest available TeX Live (big)

3. RStudio Server. The version is hardcoded, but you can change it by editing the [line in the manifest](puppet/manifests/rstudio-server.pp#L3) that sets `$rstudioserver` (or change the full download URL by also changing `$urlrstudio`).

4. Various supporting libraries, languages, and tools: Java, python, libxml2, Make, Vim, and so on.


## R packages

Finally, the Puppet manifest causes a set of R packages to be installed. This process is governed by an R script, [r-packages.R](r-packages.R). There's nothing sophisticated here, just a list of packages to be installed from CRAN (in the variable `packages`). In principle, `vagrant provision` will cause these to be upgraded if more recent versions are available than those that are installed. You can of course install packages from within R in the usual way too once the VM is up, but pedagogically speaking, the less time students spend installing tools after the first week, the better. (N.B. Vagrant's provisioning will not fail if installing packages fails, since `install.packages()` only generates a warning. It would be better to check that the packages are actually present and raise an error if not, but I don't do that here.)

Nonetheless, I can say that this setup has indeed been used by students on a variety of Mac and Windows machines. I would be very pleased to hear from anyone who makes use of any part of this repository (or any of my other online course materials). I can be reached at <andrew.goldstone@rutgers.edu>.

Andrew Goldstone  
June 2015
