# Based on https://www.youtube.com/watch?v=kG2vxYn547E
# and another sources

# In case of change ruby & alpine image from dockerhub
# remove old images and containers previous to do build
# Then, docker build .
# *** A new alpine download should appear ***

# After that, docker-compose will look for same old image on private registry
# So, instead, tag this new image - Ex: docker tag 07c38c57a9fe  hub.supercanal.tv:5000/biblioteca
# Then, push then to private registry:
# docker push hub.supercanal.tv:5000/biblioteca

FROM ruby:2.3.7-alpine3.7

LABEL maintainer="escuelaint@gmail.com"

# RUN echo “#!/bin/sh\n” > /test.sh
# RUN echo “echo \”this is version 1\”” >> /test.sh
# ENTRYPOINT [“sh”, “/test.sh”]

# Minimal requirements to run a Rails app
# postgresql-client is only to play with bin/rails dbconsole

# If image were with a Ubuntu based distro, equivalent should be
# RUN apt-get update -y \
#     apt-get install -y -q package \
#     apt-get clean \
#     rm -rf /var/lib/apt/lists/*_*
RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                vim \
                                mc \
                                postgresql-dev \
                                nodejs \
                                tzdata \
                                postgresql-client

ENV HOME=/home/s
ENV PATH=/usr/src/app/bin:$PATH

ENV LANG C.UTF-8

WORKDIR /usr/src/app

# Note: later, you can copy to/from the instance by using "docker cp"
COPY sudoers /etc
COPY Gemfile /usr/src/app
COPY Gemfile.lock /usr/src/app

RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3
RUN gem pristine --all

# Copy the application into the container.
# Prefer COPY instead ADD - see https://stackoverflow.com/questions/24958140/what-is-the-difference-between-the-copy-and-add-commands-in-a-dockerfile
COPY . /usr/src/app

# To prevent root owned files created by the container, on host filesystem
# En Ubuntu: RUN adduser --system --group --shell /bin/sh s \
#                && mkdir /home/s && chown s:s /usr/src/app -R

# In Alpine "web"
# To work with
# docker exec -it rails5dockeralpine_web_1 /bin/sh
RUN addgroup -S s && \
    adduser -u 1000 -h /home/s -D -s /bin/sh -G wheel s && \
    chown s:s /usr/src/app -R && \
    chown s:s /usr/local/lib/ruby/gems/ -R && \
    chown s:s /usr/local/bin -R && \
    chown s:s /usr/local/bundle -R

USER s

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

# Require
# RUN apk --update --no-cache add --virtual build-deps build-base python postgresql-dev nodejs g++; \
#     bundle config build.libv8 --enable-debug && \
#     LIBV8_VERSION=$LIBV8_VERSION bundle install --without development test && apk del build-deps

# Lanzamos desde el docker-compose. Pero si quisieramos lanzar por aquí, independiente...
# CMD ["bundle","exec","rails","server"]
