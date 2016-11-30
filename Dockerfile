FROM ruby:2.2.0

RUN apt-get update

# Install nodejs
RUN apt-get install -qq -y nodejs

# Install Nginx.
RUN apt-get update && apt-get install -qq -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx
RUN chmod 775 -R /var/log/nginx

# Install the latest postgresql lib for pg gem
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes libpq-dev

ENV APP /rails_app
ENV BUNDLE_PATH /box
WORKDIR $APP

# Add default nginx config
ADD config/container/nginx-sites.conf /etc/nginx/sites-enabled/default

# Add default unicorn config
ADD config/container/unicorn.rb $APP/config/unicorn.rb

ADD config/container/start-server.sh /usr/bin/start-server
RUN chmod +x /usr/bin/start-server

# Install Rails App
ADD . $APP

ENV RAILS_ENV development

EXPOSE 80