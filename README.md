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
sudo pip install docker yaml
```
* Checkout the source code:
```
git clone https://github.com/rpavlyuk/systemdock.git
```
* Install the tool:
```
sudo make install
```
* Check the confguration file ```/etc/systemdock/config.yaml``` if the settings are valid for your distribution

## Using SystemDock
* The tool has built-in help manual so check it out first:
```
systemdock --help
```
* Create SystemD service from existing Docker container. For example, let's create the one for Tomcat:
```
sudo systemdock -v -a add --name tomcat -d "tomcat:9.0"
```
* Check out file ```/etc/systemdock/containers.d/[NAME]/config.yml``` (in our example: ```/etc/systemdock/containers.d/tomcat/config.yml```) and add additional options like port forwarding and file mounts if needed. See ```examples``` for more information on options.
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

## TODO
* RPM/DEB packaging
* List all services managed by SystemDock
* Add more container options to the config file
