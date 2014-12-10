#! /bin/sh

bundle install --path vendor/bundle --without test development

# ugh. nokogiri hardcodes some absolute paths. Let's make a symlink so that they work in the sandbox.
PWD=`pwd`
PARENT=`dirname $PWD`
mkdir -p ./$PARENT
ln -s / ./$PWD
