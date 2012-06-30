#!/bin/sh

memcached -d -m 256 -l 127.0.0.1 -p 11211
rm -f log/mongrel?.pid
mongrel_rails start -e production -d -p 3001 -P log/mongrel1.pid -l log/mongrel1.log
mongrel_rails start -e production -d -p 3002 -P log/mongrel2.pid -l log/mongrel2.log
mongrel_rails start -e production -d -p 3003 -P log/mongrel3.pid -l log/mongrel3.log

