set -x

mkdir -p /var/log

export RBENV_ROOT=/usr/local/share/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

rake db:schema:load
rails server -p 10000

