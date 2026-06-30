
ARG RUBY_VERSION=2.7.7
FROM ruby:${RUBY_VERSION}-slim


WORKDIR /app
COPY Gemfile Gemfile.lock ./

RUN gem sources --remove https://rubygems.org/
RUN gem sources --remove https://gems.ruby-china.com/
RUN gem source -a https://mirrors.tuna.tsinghua.edu.cn/rubygems/ && gem install foreman && bundle install

COPY . .

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
