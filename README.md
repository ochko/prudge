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
* apt-get install postgresql postgresql-contrib
* apt-get install redis-server
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
Current ruby for prudge is 1.9.3-p551

## Running
* `git clone git://github.com/ochko/prudge.git`
* `cd prudge`
* `bundle install`

> Please attent that you can meet some errors during bundling. If you see them, just cope the text of an error in Google and you will find the name of the package which you have to install to fix your issue.

* Create database and configure in `config/database.yml`

> You will also have to create `config.yml`, `languages.yml`, `mail.yml`, `resque.yml`, `sphinx.yml`, `settings.yml` and `twitter.yml` files before entering the next step. Examples of these files can be found into the `examples` folder.

* `bundle exec rake db:schema:load`
* `bundle exec rails server` or `bundle exec foreman start`

> When starting a server you can probably get some new errors. You should carefully read the output to get rid of them. You may be asked to create folders like `tmp`, `pids` an others and give them chmod 777 in order to make the script working fine.

### Configuring Sphinx
* `cp config/examples/sphinx.yml config/sphinx.yml`
* See [Sphinx docs](http://sphinxsearch.com/docs/current.html) for additional configuration.

### Configuring safeexec
* Clone needed files from Github to any folder: `git clone https://github.com/ochko/safeexec.git`

> If you're working with Debian Linux (ex. Ubuntu) please clone a fork of safeexec using `git clone https://github.com/cemc/safeexec.git`

* `cd safeexec && make`. After this you will have a compiled binary file called `safeexec`
* Copy this file to the `prudge/judge` folder. Assuming the script is located in your home directory do this `mv safeexec ~/prudge/judge/ && cd ~/prudge/judge`
* Give setuid root permission to the binary: `cd ../sandbox && sudo chown root safeexec && sudo chmod u+s safeexec`

### Configuring Resque
* `cp config/examples/resque.yml config/resque.yml`
* Start workers `QUEUE=* bundle exec rake resque:work`

> Note that it is ok if you see nothing. It only means that workers are working as they are expected :)

## Making your site available from the Internet
After you run the script you have to install Nginx or Apache and proxy call from your domain to the needed port and Unicorn.

This is an example of the config which you should create:
```
upstream unicorn_prudge {
  server unix:/tmp/unicorn-coder.sock fail_timeout=0;
}

server {
  listen 80;
  server_name YOUR_DOMAIN;
  keepalive_timeout 5;
  root PRUDGE_PUBLIC_FOLDER (for example /home/prudge/prudge/public);
  try_files $uri/index.html $uri.html $uri @app;

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://unicorn_prudge;
  }

  error_page 500 502 503 504 /500.html;
  location = /500.html {
    root PRUDGE_PUBLIC_FOLDER (for example /home/prudge/prudge/public);
  }
}
```

## Contributing
See [Technical Debts](https://github.com/ochko/prudge/blob/master/TechDebt.md) or [Open Issues](https://github.com/ochko/prudge/issues).
* After making changes add spec, and please be sure that all specs pass
* Send me pull request. Then it could be merged ;)
* If you found any problems please report on [issues](https://github.com/ochko/prudge/issues) page. But don't post any security related issues there, send them privately.
