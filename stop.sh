mongrel_rails stop  -P log/mongrel1.pid
mongrel_rails stop  -P log/mongrel2.pid
mongrel_rails stop  -P log/mongrel3.pid
killall -9 memcached
