# Pimon

![Pimon](http://pedrocarrico.net/pimon.jpg "Pimon")

## Description
Pimon is a simple server stats monitor designed for the raspberry pi.
It uses redis lists to show the latest 6 observed statistics and also uses
highcharts to display some nice graphs on your web browser.

## What do I need to get it to work?
1. Install redis
2. Copy the supplied config.yml.sample to config.yml
3. bundle
4. ruby pimon.rb # run the sinatra app
5. ruby stats_checker.rb # collect some stats
6. go to http://localhost:4567 and PROFIT!
7. You may want to put "ruby stats_checker.rb" in your crontab to collect some stats over time

## Configuration (config.yml)
1. basic_auth - enable or disable, configure username and password
2. redis - configure the location of the redis socket

## Quirks
Pimon uses _vmstat_ and _free_ to collect it's stats from the operating system and these are only
available on operating systems that have the /proc filesystem.  
So if you want to develop on a Mac you may use the mock implementations that are in the bin directory.  
The mock implementations are programmed in C and mimic the output of _vmstat_ and _free_.  
They just change and generate some random values on the observed stats using /dev/urandom.  
To use them you must first compile them using _make_ and then include the bin directory of this project
in your $PATH to have them available when you run the stats checker.

## TODO
1. More configuration options
2. More control over the time slices
3. Disk stats

## Copyright
Licensed under the [WTFPL](http://en.wikipedia.org/wiki/WTFPL "Do What The Fuck You Want To Public License") license.
