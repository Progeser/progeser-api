#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bundle exec rails db:create db:migrate db:seed && bundle exec rails s -b 0.0.0.0
