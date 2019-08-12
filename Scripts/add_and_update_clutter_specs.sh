#!/bin/bash
# file: add_and_update_clutter_specs.sh

repo_list=`pod repo list`
if [[ $repo_list != *"git@github.com:clutter/Specs.git"* ]]; then
  bundle exec pod repo add clutter-specs git@github.com:clutter/Specs.git
fi

bundle exec pod repo update clutter-specs
