#!/bin/bash

rsync -vax --delete-after  /Users/ash/Projects/chef/cookbooks the-rebellion.net:/var/chef/
rsync -vax /Users/ash/Projects/chef/node.json the-rebellion.net:/var/chef/
rsync -vax /Users/ash/Projects/chef/solo.rb the-rebellion.net:/var/chef/