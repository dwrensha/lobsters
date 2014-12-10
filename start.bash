set -x

export RBENV_ROOT=/usr/local/share/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

RAILS_ENV=production rake db:schema:load populate_tags

rails server -p 10000 -e production

