set -x

export PATH="/usr/local/share/rbenv/versions/1.9.3-p429/bin:$PATH"

RAILS_ENV=production bundle exec rake db:schema:load populate_tags

./bin/rails server -p 10000 -e production

