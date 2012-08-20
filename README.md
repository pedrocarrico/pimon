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

## TODO
1. More configuration options
2. Have a If-Modified-Since/Last-Modified request/response HTTP header
3. More control over the time slices

## Copyright
Licensed under the [WTFPL](http://en.wikipedia.org/wiki/WTFPL "Do What The Fuck You Want To Public License") license.
