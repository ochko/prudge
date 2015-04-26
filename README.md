# Prudge
[![Build Status](https://travis-ci.org/ochko/prudge.png?branch=master)](https://travis-ci.org/ochko/prudge)
[![Code Climate](https://codeclimate.com/github/ochko/prudge.png)](https://codeclimate.com/github/ochko/prudge)
[![Coverage Status](https://coveralls.io/repos/ochko/prudge/badge.png?branch=master)](https://coveralls.io/r/ochko/prudge?branch=master)
[![Dependency Status](https://gemnasium.com/ochko/prudge.png)](https://gemnasium.com/ochko/prudge)

Prudge is an online programming contest judge system.

## Required services
* Memcached for caching
* Postgresql as database
* Redis for background processing
* Sphinx for full text search
* [safeexec](https://github.com/ochko/safeexec) for testing code

### Installin on Linux(Ubuntu/Debain)
* apt-get install memcached
* apt-get install postgresql92-server
* apt-get install redis
* apt-get install sphinxsearch

### Installing on FreeBSD
* cd /usr/ports/databases/memcached && make install clean
* cd /usr/ports/databases/postgresql92-server && make install clean
* cd /usr/ports/databases/redis && make install clean
* cd /usr/ports/textproc/sphinxsearch && make install clean

### Installing on OS X
* brew install memcached
* brew install postgresql
* brew install redis
* brew install sphinx

### Ruby
Recommends installing ruby via [rbenv](https://github.com/sstephenson/rbenv).
Current ruby for prudge is 1.9.3-p448

## Running
* `git clone git://github.com/ochko/prudge.git`
* `cd prudge`
* `bundle install`
* Create database and configure in `config/database.yml`
* `bundle exec rake db:schema:load`
* `bundle exec rails server` or `bundle exec foreman start`

### Configuring safeexec
* Initialize submodule: `git submodule update --init`
* Make binary executable: `cd judge/runner && make && mv safeexec ../sandbox/`
* Give setuid root permission to the binary: `cd ../sandbox && sudo chown root safeexec && sudo chmod u+s safeexec`

### Configuring Resque
* `cp config/examples/resque.yml config/resque.yml`
* Start workers `QUEUE=* bundle exec rake resque:work`

### Configuring Sphinx
* `cp config/examples/sphinx.yml config/sphinx.yml`
* See [Sphinx docs](http://sphinxsearch.com/docs/current.html) for additional configuration.

## Contributing
See [Technical Debts](https://github.com/ochko/prudge/blob/master/TechDebt.md) or [Open Issues](https://github.com/ochko/prudge/issues).
* After making changes add spec, and please be sure that all specs pass
* Send me pull request. Then it could be merged ;)
* If you found any problems please report on [issues](https://github.com/ochko/prudge/issues) page. But don't post any security related issues there, send them privately.
