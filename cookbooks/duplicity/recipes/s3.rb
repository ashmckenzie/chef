#
# Cookbook Name:: duplicity
# Recipe:: s3
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
package "python-boto" # for S3

template "/etc/duplicity/config.sh" do
  source "s3-config.sh.erb"
  variables :bucket => node[:duplicity][:s3][:bucket],
    :full_backups_to_keep => node[:duplicity][:full_backups_to_keep]
  mode "0644"
end

template "/etc/duplicity/keys.sh" do
  source "s3-keys.sh.erb"
  variables :passphrase => node[:duplicity][:passphrase],
    :aws_access_key_id => node[:duplicity][:s3][:aws_access_key_id],
    :aws_secret_access_key => node[:duplicity][:s3][:aws_secret_access_key]
  mode "0600"
end
