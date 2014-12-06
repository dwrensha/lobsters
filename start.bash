set -x

mkdir -p /var/log

export RBENV_ROOT=/usr/local/share/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

RAILS_ENV=production rake db:schema:load

cat | rails console production <<__EOF__
t = Tag.new
t.tag = "test"
t.save
__EOF__


rails server -p 10000 -e production

