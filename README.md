# rails5-docker-alpine

This is a very lightweight Docker image based on Ruby Alpine to run a Rails 5
application.
I also provide a docker-compose file to run your project using a PostgreSQL
database.

Based on https://github.com/pacuna/rails5-docker-alpine - thanks Pablo!

## Trying out the image

Clone the repository:

```sh
git clone git@github.com:pancutan/rails5-docker-alpine.git
```

## Install on local machine for first deploy, RVM
 (more info in rvm.io)
```sh
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash -s stable
```

> If you already has RVM
```sh
rvm get head
```

Add to ~/.bashrc or ~/.zshrc
```
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
```

Sometimes restart is needed. To avoid, do on each terminal:
```
source ~/.profile
```

## Install ruby 2.2.10
```
rvm install ruby-2.2.10 --default
rvm use ruby-2.2.10
gem install rails
```

## Check who is providing ruby
```
which ruby
```
Result should be something like
/home/your-user/.rvm/rubies/ruby-2.2.10/bin/ruby

If ruby is provided by /usr/bin/ruby, uninstall it of your linux
package manager (apt, pacman, etc)

## Create a new Rails application under the repository directory

```sh
cd rails-docker-alpine

rails new . --database=postgresql
```

## Modify your database configuration to use the postgresql container configuration:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: db
  username: postgres
```

## Unless you do testing, comment database section

# Build the project:

```sh
docker-compose build
```

# Create the database and run the migrations:

```
docker-compose run --rm web bin/rails db:create
docker-compose run --rm web bin/rails db:migrate
```

# Run the app
This is for first time to check things. Add -d if you want to detach.

```sh
docker-compose run --rm web /bin/sh
COMPOSE_HTTP_TIMEOUT=200 docker-compose up -d
```

# Exercises, just for fun
Examine database created:
```bash
$ docker exec -it rails5dockeralpine_web_1 /bin/sh
/usr/src/app $ rails dbconsole
Password:
biblioteca_development=# \l
                                       List of databases
          Name          |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
------------------------+----------+----------+------------+------------+-----------------------
biblioteca_development | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
```

Enter with root privileges, to install things
```bash
docker exec -it --user root rails5dockeralpine_web_1 /bin/sh
```

Visit your application at http://localhost:3000

# How to work
Next steps are to add code, migrations and so on to the project. You can enter and code inside the container, or you can work on where project is mount (folder .), which is linked with /usr/src/app

## Enter the container and work inside
* Database:
```bash
docker exec -it rails5dockeralpine_postgres_1 /bin/bash
```
* Web app:
```bash
docker exec -it rails5dockeralpine_web_1 /bin/sh
```

If you want to work on your local mounted folder, go ahead:

First things you have to keep on mind is that scripts must run inside the container.
Take for instance, I use to debug with Pry. In that so, in Gemfile I remove byebug and put inside, on development and test section:
```gemfile
gem 'pry-auditlog' # Ver en ~/.pryrc en esta carpeta ~/Trucos/Ruby/Debug/
gem 'pry'
gem 'pry-byebug'
gem 'pry-rescue'
gem 'pry-stack_explorer'
gem 'pry-auditlog'
gem 'pry-rails'
gem 'awesome_print'
```

After that, a bundled is needed:
```bash
docker-compose run --rm web bin/bundle install
docker-compose run --rm web bin/rails generate scaffold author name:string surname:string
```

Tested with:
- Ruby 2.2.10
- Rails 5.2 (to create the new application)
- Docker version 18.03.0-ce, build 0520e2430
- docker-compose version 1.21.0, build unknown

- Local
  - rvm
  - DISTRIB_ID=ManjaroLinux
  - DISTRIB_RELEASE=17.1.8
  - DISTRIB_CODENAME=Hakoila


# TODO
At this time (2018/04/14) Rails 5.2 is stable under ruby 2.2.10
so, try a modern ruby, like 2.4.4 with actual stable Alpine - ruby:2.4.4-alpine3.6
Ref:
* https://hub.docker.com/_/ruby/
  * → https://github.com/docker-library/ruby/blob/1bd8b466277668bff50528b26360e6e451e4dae4/2.4/alpine3.6/Dockerfile

# Greetings:
* https://github.com/IcaliaLabs/guides/wiki/Creating-a-new-Rails-application-project-with-Docker
* https://github.com/pacuna/rails5-docker-alpine - thanks, again, Pablo!
