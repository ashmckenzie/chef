#
# Cookbook Name:: duplicity
# Recipe:: cloudfiles
#
# Copyright 2011, Marcel M. Cary
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "duplicity"
package "python-rackspace-cloudfiles"

template "/etc/duplicity/config.sh" do
  source "cloudfiles-config.sh.erb"
  variables :bucket => node[:duplicity][:cloudfiles][:bucket],
    :full_backups_to_keep => node[:duplicity][:full_backups_to_keep]
  mode "0644"
end

template "/etc/duplicity/keys.sh" do
  source "cloudfiles-keys.sh.erb"
  variables :passphrase => node[:duplicity][:passphrase],
    :username => node[:duplicity][:cloudfiles][:username],
    :apikey => node[:duplicity][:cloudfiles][:apikey]
  mode "0600"
end
