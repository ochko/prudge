# Prudge

Prudge is an online programming contest judge system.

## Required services
* Memcached for caching
* Postgresql as database
* Redis for background processing
* [safeexec](https://github.com/ochko/safeexec) for testing code

### Installin on Linux(Ubuntu/Debain)
* apt-get install memcached
* apt-get install postgresql92-server
* apt-get install redis

### Installing on FreeBSD
* cd /usr/ports/databases/memcached && make install clean
* cd /usr/ports/databases/postgresql92-server && make install clean
* cd /usr/ports/databases/redis && make install clean

### Installing on OS X
* brew install memcached
* brew install postgresql
* brew install redis

### Ruby
Recommends installing ruby via [rbenv](https://github.com/sstephenson/rbenv).
Current ruby for prudge is 1.8.7

## Running
* `git clone git://github.com/ochko/prudge.git`
* `cd prudge`
* `bundle install`
* Create database and configure in `config/database.yml`
* `bundle exec rake db:schema:load`
* `bundle exec script/server` then open http://0.0.0.0:3000 in browser

### Configuring safeexec
* Download safeexec somewhere `git://github.com/ochko/safeexec.git`
* `cd safeexec && make`
* Move compiled binary to judge directory `mv safeexec ~/prudge/judge/ && cd ~/prudge/judge`
* Then set permissions `sudo chown root safeexec && sudo chmod u+s safeexec`
* Configure resque in `config/resque.yml`, then start workers `bundle exec resque work`

## Future Plan
* Upgrade rails/ruby version 2.3/1.8.7 => 3.2/1.9.3 => 4.0/2.0


## Contributing
* After making your changes please add specs for your changes, and please make sure all specs pass
* Send pull request. Then I might merge ;)
* If you found any problems please add on github/issues page. But don't post any security related issues there. Please send me privately.
