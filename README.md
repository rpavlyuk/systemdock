# SystemDock
Toolset to run Docker containers as systemd service on RedHat and other Linux systems

## Author and Credits
Roman Pavlyuk <roman.pavlyuk@gmail.com>

http://roman.pavlyuk.lviv.ua/

## Why would I need this?
Docker is a the most prominent technology invented in the last years which makes sane execution of various applications very easy. Docker's philosphy is based on the principle: one container -- one application. But what if you'd like to run your "dockerized" application as SystemD service with all the benefits like starting it on boot? SystemDock is what you actually need then.

## Get Started
* SystemDock is mostly written in Python and uses some 3rd party libraries. Let's install them first:
```
sudo pip3 install docker yaml
```
* Checkout the source code:
```
git clone https://github.com/rpavlyuk/systemdock.git ./
```
* RedHat family users, use RPM installer to install the tool:
```
sudo make install-rpm clean
```
* Others, install the tool using "old school" way:
```
sudo make install clean
```
* Check the confguration file ```/etc/systemdock/config.yaml``` if the settings are valid for your distribution

## Using SystemDock
* The tool has built-in help manual so check it out first:
```
systemdock --help
```
* List all services that are currently managed by SystemDock:
```
systemdock -a list
```
* Create SystemD service from existing Docker container. For example, let's create the one for Tomcat:
```
sudo systemdock -v -a add --name tomcat -d "tomcat:9.0"
```
* Check out file ```/etc/systemdock/containers.d/[NAME]/config.yml``` (in our example: ```/etc/systemdock/containers.d/tomcat/config.yml```) and add additional options like port forwarding and file mounts if needed. See ```examples``` for more information on options.
Options correspond to Containers.run() function parameters. Please, see the reference here: https://docker-py.readthedocs.io/en/stable/containers.html#docker.models.containers.ContainerCollection.run
* **NOTE**: You may either allow SystemDock to use only validated set of startup options or allow it to accept any other parameters which [Containers.run()](https://docker-py.readthedocs.io/en/stable/containers.html#docker.models.containers.ContainerCollection.run) function can support. This setting can be controlled in SystemDock's configuration file (by default: ```/etc/systemdock/config.yaml```) by using parameter ```container.enable_user_options```.
* You can check if the service is listed in those that are managed by SystemDock:
```
systemdock -a list
```
* Additionally, you can get detailed information about the specific service (profile):
```
systemdock -a list -n tomcat
```
* Now, start dockerized Tomcat as systemd service. Note, that services are being created as "systemdock-[NAME]". In our example it will be ```systemdock-tomcat```:
```
sudo systemctl start systemdock-tomcat
```
**NOTE:** As you know, Docker is pulling the image from repository when the container is run for the first time. So, be patient when launching the service for the first time.
* Check if the service is running:
```
sudo systemctl status systemdock-tomcat
```
* Enable the service to start on boot:
```
sudo systemctl enable systemdock-tomcat
```
* If required to stop the service:
```
sudo systemctl stop systemdock-tomcat
```
* To remove the service from SystemD:
```
sudo systemdock -v -a remove --name tomcat
```
## Developing SystemDock
Enhancing SystemDock is easy -- it already has Vagrant-based dev environment configuration.
* Install [Vagrant](https://developer.hashicorp.com/vagrant) and (most likely) [VirtualBox](https://www.virtualbox.org/wiki/Downloads) which Vagrant is using as default hypervisor.
* Go to ```SystemDock``` source root and init the Vagrant:
```
vagrant init
```
* Start and provision the VM:
```
vagrant up --provision
```
* Access the VM and install SystemDock:
```
vagrant ssh
...
cd /srv/systemdock
sudo make install
sudo systemdock -a list
```
* Re-install SystemDock from host (your development) machine:
```
vagrant rsync && vagrant ssh -c "cd /srv/systemdock && sudo make install"
```
* Stop and (optionally) destroy the VM once you're done:
```
vagrant halt
vagrant destroy -f
```


## TODO
* Test on other distros: Ubuntu, SUSE, etc
* Add more container options to the config file
