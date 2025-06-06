### ------- Builder ------- ###
FROM ruby:3.3.7-alpine AS builder

ENV HOME /app 
ENV RAILS_ENV production 
ENV RAILS_SERVE_STATIC_FILES true 
ENV SECRET_KEY_BASE abcdefgh12345678 
WORKDIR $HOME

RUN apk update && apk upgrade && \
    apk add --update --no-cache nodejs yarn build-base libxml2-dev libxslt-dev tzdata postgresql-dev ruby-dev gcompat yaml-dev && \
    rm -rf /var/cache/apk/* 

# # speed up install of nokogiri gem
RUN gem update bundler && \
    bundle config --local build.nokogiri --use-system-libraries && \
    bundle config set without 'development test' && \
    bundle config set --local path 'vendor/bundle' && \
    bundle config set force_ruby_platform true 

ADD .ruby-version $HOME/
ADD Gemfile* $HOME/

# # speed up install of nokogiri gem
RUN bundle install --jobs 4

# Add the app code
COPY . $HOME

RUN yarn install && \
    bundle exec rake assets:precompile

# delete unneeded files
RUN rm -rf node_modules tmp/cache vendor/assets spec


### ------- Production ------- ###
FROM ruby:3.3.7-alpine

ENV HOME /app 
ENV RAILS_ENV production 
ENV RAILS_SERVE_STATIC_FILES true 
ENV SECRET_KEY_BASE abcdefgh12345678
WORKDIR $HOME

RUN apk update && apk upgrade && \
    apk add --update --no-cache \
        nodejs libxslt-dev tzdata imagemagick postgresql-client && \
    rm -rf /var/cache/apk/* 

# Install gems
RUN gem update bundler && \
    bundle config set without 'development test' && \
    bundle config set --local deployment 'true' && \
    bundle config set --local path 'vendor/bundle'

COPY --from=builder /app /app
