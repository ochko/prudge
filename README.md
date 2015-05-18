# Prudge
[![Build Status](https://travis-ci.org/ochko/prudge.png?branch=master)](https://travis-ci.org/ochko/prudge)
[![Code Climate](https://codeclimate.com/github/ochko/prudge.png)](https://codeclimate.com/github/ochko/prudge)
[![Coverage Status](https://coveralls.io/repos/ochko/prudge/badge.png?branch=master)](https://coveralls.io/r/ochko/prudge?branch=master)
[![Dependency Status](https://gemnasium.com/ochko/prudge.png)](https://gemnasium.com/ochko/prudge)

Prudge is an online programming contest judge system.

# Installing

On your local development machine checkout the source. Of course you'll need ruby.

* `git clone git://github.com/ochko/prudge.git`
* `cd prudge`
* `bundle install`

There are two ways to install prudge -- Ansible or Manual.

## Install using Ansible

Install [ansible](http://docs.ansible.com/intro_installation.html) on your local machine. Ansible is a simple automation tool for deployment. Ensure you have an ssh access to your server, and able to run commands as a root(sudo).
Customize `setup/vars/common.yml`. Generate password hash with `$ mkpasswd --method=SHA-512` for `prudge_user_pwd`.
Modify `setup/server` file with your own server's hostname.

And run this command replacing `yourlogin` with your ssh user's login:
`$ ansible-playbook -i testing -u yourlogin --become --ask-become-pass site.yml --extra-vars "user=yourlogin"`

## Manual install

You can install prudge manually if ansible playbook is not available for your platform or simply you don't want to use ansible.

### Dependencies

During manual installation you'll install and configure these services for prudge.

* Memcached for caching
* Redis for background processing
* Sphinx for full text search
* Postgresql as database
* Git for getting source codes
* [safeexec](https://github.com/ochko/safeexec)

### Configuration files

Create a directory on your server. Lets say `/usr/local/apps/prudge`. Then create subdirectories:

```
/usr/local/apps/prudge/shared/config
/usr/local/apps/prudge/shared/script

```

Copy configuration files from `config/examples`.
Copy scripts from `setup/templates/script` removing `.j2` from filenames. Replace chunks like `{{ ... }}` with appropriate value.
These shared files will be linked to application directory when you deploy.

### Ruby

Install ruby via [rbenv](https://github.com/sstephenson/rbenv).
When your rbenv and ruby-build is ready do:

* `$ rbenv install 1.9.3-p551` or whatever ruby version specified in `.ruby-version` file.
* `gem install bundler`

### Database

Install postgresql. And create user and database. Update database configuration in `config/database.yml`.

### Sphinx
* `cp config/examples/sphinx.yml config/sphinx.yml`
* See [Sphinx docs](http://sphinxsearch.com/docs/current.html) for additional configuration.

### Safeexec

Prudge uses [safeexec](https://github.com/ochko/safeexec) for running user programs. You'll need `cmake` to build safeexec and also need root permission(sudo) to install it.

* `git clone https://github.com/ochko/safeexec.git && cd safeexec`
* `cmake . && sudo make install`.
* Now your should have a binary called `safeexec` -- `which safeexec`. Update `runner` path in `config/binaries.yml`.

### Resque

Prudge uses [resque](https://github.com/resque/resque) for background tasks such as checking submitted solutions, notifying users etc.
Resque uses redis, so install redis and start it. Then run resque workers:

`nohup bundle exec rake resque:work RAILS_ENV=production QUEUE=* PIDFILE=tmp/pids/resque.pid > log/resque.log 2>&1 &`

### Binary executables

Prudge uses some external binaries -- safeexec, git and diff. Configure those in `config/binaries.yml`. Use `which` if don't know where is a binary, e.g `which safeexec`.

### Mail delivery

Prudge needs to send emails for resetting forgotten password, notifying new contest announcement etc. Configure mail delivery settings in `config/mail.yml`.
See [Action Mailer docs](http://guides.rubyonrails.org/action_mailer_basics.html#example-action-mailer-configuration) for detail.

## Deploying

Prudge uses [capistrano](http://capistranorb.com) for deployments.

* `cp config/deploy/example.rb config/deploy/production.rb`. And update `production.rb` with your server's info.
* `bundle exec cap production deploy`
* `bundle exec cap production deploy:seed`
* `bundle exec cap production deploy:monit`

You'll need to run `deploy:seed` task only once on your first deploy. Seeding creates minimal database records. See `db/seeds.rb` for details.

## Web server

It is time to open your shiny new site to the world. Install nginx. Put contents of `setup/templates/web/nginx.conf.j2` into `nginx/sites-available/prudge.conf`. Replace all `{% ... %}` and `{{ ... }}` with desired values.

## Contributing

See [Technical Debts](https://github.com/ochko/prudge/blob/master/TechDebt.md) or [Open Issues](https://github.com/ochko/prudge/issues).
* After making changes add spec, and please be sure that all specs pass
* Send me pull request. Then it could be merged ;)
* If you found any problems please report on [issues](https://github.com/ochko/prudge/issues) page. But don't post any security related issues there, send them privately.

## License

The MIT License (MIT)

Copyright (c) Lkhagva Ochirkhuyag, 2009-2015

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
