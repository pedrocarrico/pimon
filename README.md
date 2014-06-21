# Pimon

[![Build Status](https://secure.travis-ci.org/pedrocarrico/pimon.png)](http://travis-ci.org/pedrocarrico/pimon) [![Dependency Status](https://gemnasium.com/pedrocarrico/pimon.png?travis)](https://gemnasium.com/pedrocarrico/pimon) [![Gem Version](https://badge.fury.io/rb/pimon.png)](http://badge.fury.io/rb/pimon) [![Code Climate](https://codeclimate.com/github/pedrocarrico/pimon.png)](https://codeclimate.com/github/pedrocarrico/pimon) [![Coverage Status](https://coveralls.io/repos/pedrocarrico/pimon/badge.png?branch=master)](https://coveralls.io/r/pedrocarrico/pimon)

![Pimon](http://pedrocarrico.net/pimon.jpg "Pimon")

## Description
Pimon is a simple server monitor designed for the Raspberry Pi.

## What do I need to get it to work?
1. Clone this repo: git clone git://github.com/pedrocarrico/pimon.git
2. bundle
3. bin/pimon start # run the sinatra app
4. go to http://localhost:3000 and PROFIT!
Optionally you may install it as a gem and run it, please check "Installing as a gem" further down.

## Configuration
Configuration is done through a YAML file, you may check some examples on the config directory.

1. chart - colors for each chart
2. hostname - optional hostname to show on the chart subtitle, defaults to `hostname` if not set
3. stats_collector - configure number of stats and time period between them

## Installing as a gem
```
gem install pimon
```
After installation just do _pimon start_ and go to http://localhost:3000 and check your stats.
If you want you may run Pimon with other options:
```
Usage: pimon start|stop [options]
Options:
    -c, --config CONFIG              YAML configuration file for pimon
    -d, --daemonize                  Run Pimon daemonized in the background
    -e, --environment ENVIRONMENT    Application environment (default: "development", options: "development", "production")
    -i, --interface INTERFACE        Hostname or IP address of the interface to listen on (default: "localhost")
    -p, --port PORT                  Port to use (default: 3000)
    -P, --pid PIDFILE                File to store PID (default: /tmp/pimon.pid)
```
(This will only work on your Raspberry Pi and perhaps some other linux distros, check the quirks section for more info).

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
in your $PATH to have them available when you run the sinatra application.
The temperature stat is available with the latest Raspbian and Arch Linux distros on your Raspberry Pi and will
(may) not work if you're developing on other systems.
Pimon only works with Ruby 1.9+.

## TODO
1. Improve disk stats, have a way of having custom mount points
2. Change configuration in realtime
3. Cpu frequency probe
4. Persist stats

## Copyright
Licensed under the [WTFPL](http://en.wikipedia.org/wiki/WTFPL "Do What The Fuck You Want To Public License") license.
