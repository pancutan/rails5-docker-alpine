FROM ruby:2.2.10-alpine3.4

LABEL maintainer="escuelaint@gmail.com"

# RUN echo “#!/bin/sh\n” > /test.sh
# RUN echo “echo \”this is version 1\”” >> /test.sh
# ENTRYPOINT [“sh”, “/test.sh”]

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                vim \
                                mc \
                                postgresql-dev \
                                nodejs \
                                tzdata \
                                sudo

ENV HOME=/home/s
ENV PATH=/usr/src/app/bin:$PATH

ENV LANG C.UTF-8

WORKDIR /usr/src/app

# To prevent root owned files created by the container, on host filesystem
# En Ubuntu: RUN adduser --system --group --shell /bin/sh s \
#                && mkdir /home/s && chown s:s /usr/src/app -R

# In Alpine "web"
# To work with
# docker exec -it rails5dockeralpine_web_1 /bin/sh
RUN addgroup -S s && \
    adduser -u 1000 -h /home/s -D -s /bin/sh -G wheel s && \
    chown s:s /usr/src/app -R

USER s

# Note: later, you can copy to/from the instance by using "docker cp"
COPY sudoers /etc
COPY Gemfile /usr/src/app
COPY Gemfile.lock /usr/src/app

RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

# Copy the application into the container.
# Prefer COPY instead ADD - see https://stackoverflow.com/questions/24958140/what-is-the-difference-between-the-copy-and-add-commands-in-a-dockerfile
COPY . /usr/src/app

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


