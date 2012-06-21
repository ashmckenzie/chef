#
# Cookbook Name:: duplicity
# Recipe:: default
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

package "duplicity"
directory "/etc/duplicity"
# Provide a few common commands so I don't have to remember the syntax
%w{backup cleanup full_backup restore status expire}.each do |script|
  cookbook_file "/etc/duplicity/#{script}" do
    mode "0555"
  end
end

template "/etc/duplicity/files.txt" do
  cb = node[:duplicity][:files_cookbook]
  cookbook cb if cb
  mode "0655"
end
