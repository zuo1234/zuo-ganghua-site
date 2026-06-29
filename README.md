# Zuo Ganghua Site

Rails + Stimulus personal site for 左刚华.

The app includes a personal homepage, technical posts, terminal-style mini games,
a photo gallery, and lightweight admin screens for managing posts and photos.

## Stack

- Ruby 2.7.7
- Rails 7.0
- Stimulus
- SQLite
- Sprockets

## Local Development

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Open `http://localhost:3000`.

Admin pages are available in development without credentials:

- `/admin/posts`
- `/admin/photos`

In production, set `ADMIN_USERNAME` and `ADMIN_PASSWORD` to enable HTTP Basic
Auth for admin pages.

## Docker

Build the image:

```sh
docker build -t zuo-ganghua-site .
```

The Dockerfile defaults to a Huawei Cloud SWR Ubuntu base image, Huawei Cloud
APT/Rubygems mirrors, and builds Ruby 2.7.7 inside the image. It uses Ubuntu
24.04 to match the server and builds OpenSSL 1.1.1w separately for Ruby 2.7.7
compatibility. This avoids pulling the official `ruby:*` image from Docker Hub
on Huawei Cloud servers. To use a different SWR region, private mirrored base
image, or internal mirrors:

```sh
docker build \
  --build-arg BASE_IMAGE=swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/library/ubuntu:24.04 \
  --build-arg OPENSSL_VERSION=1.1.1w \
  --build-arg UBUNTU_MIRROR=https://mirrors.huaweicloud.com/ubuntu \
  --build-arg RUBYGEMS_MIRROR=https://mirrors.huaweicloud.com/repository/rubygems \
  --build-arg RUBY_DOWNLOAD_URL=https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.7.tar.gz \
  -t zuo-ganghua-site .
```

Run it with a persistent SQLite volume:

```sh
docker run --rm -p 3000:3000 \
  -e SECRET_KEY_BASE=change-me \
  -e ADMIN_USERNAME=admin \
  -e ADMIN_PASSWORD=change-me \
  -v zuo_ganghua_site_storage:/rails/storage \
  zuo-ganghua-site
```

For production, replace `SECRET_KEY_BASE`, `ADMIN_USERNAME`, and
`ADMIN_PASSWORD` with real secret values.
