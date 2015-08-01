# netdot
This docker image runs [NetDot](https://osl.uoregon.edu/redmine/projects/netdot)
# Dependancies
* MySql container, for example : ``docker run -d --name=mysql -e MYSQL_ROOT_PASSWORD=MyPassword mysql``
* Mail Relay container (optional)

# Settings
If you run it with ``-v "/your/local/disk/directory":/usr/local/netdot/etc`` it will create a config file there

#QuickStart
``docker run -d --name=mysql -e MYSQL_ROOT_PASSWORD=MyPassword mysql``

``docker run -d --name=netdot --link mysql:mysql -v "/your/local/disk/directory":/usr/local/netdot/etc niklasskoldmark/netdot``

Browse to : http://your.docker.host.address/netdot

Username : admin

Password : admin
