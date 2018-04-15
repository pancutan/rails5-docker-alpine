FROM ruby:2.2.10-alpine3.4

LABEL maintainer="escuelaint@gmail.com"

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                postgresql-dev \
                                nodejs \
                                tzdata

ENV APP_PATH /usr/src/app
ENV LANG C.UTF-8

# Different layer for gems installation
WORKDIR $APP_PATH

ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH

RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

# Copy the application into the container
COPY . APP_PATH
EXPOSE 3000

# Otras cosas para hacer

# Consejos de https://hub.docker.com/_/rails/
# Esta depreacted, porque lo unico que hace falta es agregar al Dockerfile de https://hub.docker.com/_/ruby/

# Tener en cuenta ademas
# Lesson 1: gems with C bindings cause problems
# https://medium.com/@igor.petrov/lessons-learned-from-first-attempt-of-dockerizing-ruby-on-rails-app-7e5eb9004265

# APIQ has a dependency on well-known therubyracer (and actually
# libv8) gem. If you ever worked on dockerizing Rails app with
# such dependency, you know what I’m talking about. After
# spending some time on googling, I’ve came to this:
# ENV LIBV8_VERSION 3.16.14.18

# Requiere
# RUN apk --update --no-cache add --virtual build-deps build-base python postgresql-dev nodejs g++; \
#     bundle config build.libv8 --enable-debug && \
#     LIBV8_VERSION=$LIBV8_VERSION bundle install --without development test && apk del build-deps


