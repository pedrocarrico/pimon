# Pimon

[![Build Status](https://secure.travis-ci.org/pedrocarrico/pimon.png)](http://travis-ci.org/pedrocarrico/pimon) [![Dependency Status](https://gemnasium.com/pedrocarrico/pimon.png?travis)](https://gemnasium.com/pedrocarrico/pimon) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/pedrocarrico/pimon)

![Pimon](http://pedrocarrico.net/pimon.jpg "Pimon")

## Description
Pimon is a simple server stats monitor designed for the raspberry pi.
It uses redis lists to show the latest 6 observed statistics and also uses
highcharts to display some nice graphs on your web browser.

## What do I need to get it to work?
1. Install redis an configure it to run on a socket on /tmp/redis.sock
2. bundle
3. bin/pimon start # run the sinatra app
4. go to http://localhost:3000 and PROFIT!

## Configuration
1. basic_auth - enable or disable, configure username and password
2. redis - location of the redis socket
3. chart - colors for each chart
4. queues - redis list names for the series in the charts
5. stats - configure number of stats and time period between them

## Deployment
To deploy on your raspberry pi you just have to have ssh enabled and your keys authorized.  
Then you can deploy with capistrano using:  
```
cap deploy:setup
cap deploy:cold
```

This will setup your raspberry pi and deploy the application.  
The username and password for the basic_auth in the production environment will be asked in the
first deploy.
To start and stop the application you have the usual:  
```
cap deploy:start
cap deploy:stop
```

## Running tests
To run the coverage suite:
```
rake coverage:spec
```
Results will be in coverage/index.html directory.

## Quirks
Pimon uses _vmstat_ and _free_ to collect it's stats from the operating system and these are only
available on operating systems that have the /proc filesystem.  
So if you want to develop on a Mac you may use the mock implementations that are in the bin directory.  
The mock implementations are programmed in C and mimic the output of _vmstat_ and _free_.  
They just change and generate some random values on the observed stats using /dev/urandom.  
To use them you must first compile them using _make_ and then include the bin directory of this project
in your $PATH to have them available when you run the stats checker.
The temperature stat is only available with the latest Raspbian distro (2012-09-18) on your Raspberry Pi and will (may)
not work if you're developing on other systems.

## TODO
1. Improve disk stats, have a way of having custom mount points
2. Capistrano task to reset production basic_auth username and password
3. Show uptime
4. Change configuration in realtime

## Copyright
Licensed under the [WTFPL](http://en.wikipedia.org/wiki/WTFPL "Do What The Fuck You Want To Public License") license.
