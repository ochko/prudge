# Prudge

Prudge is an online programming contest judge system.

## Required services
* Memcached for caching
* Postgresql as database
* Redis for background processing
* safeexec(https://github.com/ochko/safeexec) for testing code

### Installin on Linux(Ubuntu/Debain)
* apt-get install memcached
* apt-get install postgresql
* apt-get install redis

### Installing on FreeBSD
* port install memcached
* port install mysql5-server
* port install redis

### Installing on OS X
* brew install memcached
* brew install postgresql
* brew install redis

## Running
* `git clone git://github.com/ochko/prudge.git`
* `cd prudge`
* `bundle install`
* Create database and configure in `config/database.yml`
* Configure resque in `config/resque.yml`, then start workers `bundle exec resque work`
* `bundle exec rake db:schema:load`
* `bundle exec script/server` then open http://0.0.0.0:3000 in browser

## Contributing
* After making your changes please add specs for your changes, and please make sure all specs pass
* Send pull request. Then I might merge ;)
* If you found any problems please add on github/issues page. But don't post any security related issues there. Please send me privately.
