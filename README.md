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

The Dockerfile uses the official Ruby 2.7.7 slim image, installs the native
dependencies needed by SQLite, runs `bundle install`, precompiles assets, and
starts Rails with Puma. If Docker Hub is slow on Huawei Cloud, configure a
Docker registry mirror on the server or override the Ruby version tag:

```sh
docker build \
  --build-arg RUBY_VERSION=2.7.7 \
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

## AI Chat

The `/chat` page uses the OpenAI-compatible Responses API through the
`ruby-openai` gem. Set these runtime environment variables before starting
Rails or Docker:

```sh
OPENAI_API_KEY=your_api_key
OPENAI_API_BASE_URL=https://vibe.soyoung.com/
OPENAI_MODEL=gpt-5.6-terra
OPENAI_REQUEST_TIMEOUT=60
AI_CHAT_ENABLED=true
AI_CHAT_RATE_LIMIT=12
```

`AI_CHAT_RATE_LIMIT` is the per-IP request limit in a five-minute window. The
chat is disabled until `OPENAI_API_KEY` is configured; the key stays on the
server and is never sent to the browser. Set `OPENAI_API_BASE_URL` to the
official OpenAI endpoint or another OpenAI-compatible gateway as needed.
