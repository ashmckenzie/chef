#!/bin/bash

#HOST='the-rebellion.net'
HOST='root@199.231.227.104'

rsync -vax --delete-after  /Users/ash/Projects/chef/cookbooks ${HOST}:/var/chef/
rsync -vax /Users/ash/Projects/chef/node.json ${HOST}:/var/chef/
rsync -vax /Users/ash/Projects/chef/solo.rb ${HOST}:/var/chef/
