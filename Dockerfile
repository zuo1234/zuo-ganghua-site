# syntax=docker/dockerfile:1

ARG RUBY_VERSION=2.7.7
ARG BASE_IMAGE=swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/library/ubuntu:24.04
ARG OPENSSL_VERSION=1.1.1w
ARG UBUNTU_MIRROR=https://mirrors.huaweicloud.com/ubuntu
ARG RUBY_DOWNLOAD_URL=https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.7.tar.gz
ARG RUBYGEMS_MIRROR=https://mirrors.huaweicloud.com/repository/rubygems

FROM ${BASE_IMAGE} AS ruby-build

ARG RUBY_VERSION
ARG OPENSSL_VERSION
ARG UBUNTU_MIRROR
ARG RUBY_DOWNLOAD_URL
ARG RUBYGEMS_MIRROR

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i "s|http://archive.ubuntu.com/ubuntu|${UBUNTU_MIRROR}|g; s|http://security.ubuntu.com/ubuntu|${UBUNTU_MIRROR}|g" /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      ca-certificates \
      curl \
      libffi-dev \
      libgdbm-dev \
      libncurses5-dev \
      libreadline-dev \
      libyaml-dev \
      zlib1g-dev && \
    curl -fsSL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o /tmp/openssl.tar.gz && \
    mkdir -p /tmp/openssl-src && \
    tar -xzf /tmp/openssl.tar.gz -C /tmp/openssl-src --strip-components=1 && \
    cd /tmp/openssl-src && \
    ./config --prefix=/usr/local/openssl-1.1 --openssldir=/usr/local/openssl-1.1 shared zlib && \
    make -j"$(nproc)" && \
    make install_sw && \
    curl -fsSL "${RUBY_DOWNLOAD_URL}" -o /tmp/ruby.tar.gz && \
    mkdir -p /tmp/ruby-src && \
    tar -xzf /tmp/ruby.tar.gz -C /tmp/ruby-src --strip-components=1 && \
    cd /tmp/ruby-src && \
    ./configure --prefix=/usr/local --disable-install-doc --with-openssl-dir=/usr/local/openssl-1.1 && \
    make -j"$(nproc)" && \
    make install && \
    gem sources --clear-all && \
    gem sources --add "${RUBYGEMS_MIRROR}" && \
    gem update --system 3.1.6 && \
    gem install bundler -v 2.1.4 && \
    rm -rf /tmp/openssl.tar.gz /tmp/openssl-src /tmp/ruby.tar.gz /tmp/ruby-src /var/lib/apt/lists /var/cache/apt/archives

FROM ${BASE_IMAGE} AS base

ARG UBUNTU_MIRROR

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=ruby-build /usr/local /usr/local

WORKDIR /rails

ENV BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    GEM_HOME=/usr/local/bundle \
    PATH=/usr/local/bundle/bin:/usr/local/bin:$PATH \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1

RUN sed -i "s|http://archive.ubuntu.com/ubuntu|${UBUNTU_MIRROR}|g; s|http://security.ubuntu.com/ubuntu|${UBUNTU_MIRROR}|g" /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      ca-certificates \
      curl \
      libffi8 \
      libgdbm6t64 \
      libncurses6 \
      libreadline8t64 \
      libsqlite3-0 \
      libyaml-0-2 \
      tzdata \
      zlib1g && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

FROM base AS build

ARG RUBYGEMS_MIRROR

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libsqlite3-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle config set mirror.https://rubygems.org "${RUBYGEMS_MIRROR}" && \
    bundle lock --add-platform x86_64-linux aarch64-linux && \
    bundle install && \
    cp Gemfile.lock /tmp/Gemfile.lock && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

RUN cp /tmp/Gemfile.lock Gemfile.lock && \
    SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

FROM base

ENV BUNDLE_DEPLOYMENT=1 \
    BUNDLE_FROZEN=1

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p db log storage tmp/pids tmp/cache && \
    chown -R rails:rails db log storage tmp

USER rails:rails

EXPOSE 3000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
