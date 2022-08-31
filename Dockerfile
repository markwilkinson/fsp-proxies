FROM ruby:3.0.0

RUN gem install bundler:2.2.31
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN mkdir -p /app

COPY proxy.rb /app
COPY Gemfile /app
COPY Gemfile.lock /app
COPY fsp-proxies-server.gemspec /app
COPY entrypoint.sh /app

WORKDIR /app

RUN bundle install

ENTRYPOINT ["sh", "entrypoint.sh"]

