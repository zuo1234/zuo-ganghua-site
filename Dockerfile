FROM ruby:2.7.7

WORKDIR /rails

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1


COPY Gemfile Gemfile.lock ./

RUN bundle config set mirror.https://rubygems.org https://mirrors.aliyun.com/rubygems/ && \
    bundle install

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

EXPOSE 3000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]