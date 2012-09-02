# execute "apt-get update"

%w{
  build-essential
  zlib1g-dev
  libssl-dev
  libreadline-dev
  libyaml-dev
  ntp
  ntpdate
  curl
  wget
  autoconf
  bison
  make
  git-core
  ack-grep
  vim-nox
  rsnapshot
  zsh
}.each do |pkg|
  package pkg
end

include_recipe 'postfix'

bash 'configure postfix' do
  user 'root'
  cwd '/tmp'
  code <<-EOS
postconf -e inet_interfaces=loopback-only
postconf -e myhostname=the-rebellion
postconf -e mydomain=the-rebellion.net
  EOS
end

bash 'setup ack alternative' do
  user 'root'
  cwd '/tmp'
  code 'update-alternatives --install /usr/bin/ack ack /usr/bin/ack-grep 0'
end

bash 'set locale to AU' do
  user 'root'
  cwd '/tmp'
  code <<-EOS
cat > /etc/default/locale << EOSS
LANG='en_AU.UTF-8'
LANGUAGE='en_AU:en'
EOSS
dpkg-reconfigure locales > /dev/null 2>&1
  EOS
end

# include_recipe 'nginx::source'

bash 'ensure all nginx sites are owned by apps:apps and 644' do
  user 'root'
  cwd '/tmp'
  code <<-EOS
chown -R apps:apps /etc/nginx/sites-available /etc/nginx/sites-enabled
chmod 2775 /etc/nginx/sites-available /etc/nginx/sites-enabled
chmod 644 /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
  EOS
end

bash 'ensure ruby permissions are good' do
  user 'root'
  cwd '/tmp'
  code <<-EOS
chown -R root:sudo /opt/ruby*
chmod -R g=u /opt/ruby*
  EOS
end

group 'apps'

user 'apps' do
  comment 'Applications Users'
  gid 'apps'
  home '/home/apps'
  shell '/usr/bin/zsh'
  system true
  supports :manage_home => true
end

cookbook_file "/etc/cron.d/mongodump" do
  source "mongodump.cron"
  mode "0644"
end

cookbook_file "/usr/local/bin/mongobackup" do
  source "mongobackup"
  mode "0750"
  owner "root"
  group "adm"
end

gem_package 'activesupport'
gem_package 'bundler'
gem_package 'unicorn'

directory "/var/backups/rsnapshot" do
  mode "2755"
end

cookbook_file "/etc/cron.d/rsnapshot" do
  source "rsnapshot.cron"
  mode "0644"
end

cookbook_file "/etc/rsnapshot.conf" do
  mode "0644"
end

cookbook_file "/etc/profile.d/ruby.sh" do
  source "ruby.sh"
  mode "0644"
end

# zsh prompt
#
directory "/etc/zsh/functions" do
  owner "root"
  group "root"
  mode "755"
end

zsh_files = {
  :git_cwd_info => 644,
  :ruby_current_version => 644
}

cookbook_file "/etc/zsh/zshenv" do
  mode "644"
end

link "/etc/zsh/zlogin" do
  to "/etc/zsh/zshenv"
end

zsh_files.each do |file, perms|
  cookbook_file "/etc/zsh/functions/#{file}" do
    mode "#{perms}"
  end
end

cookbook_file "/etc/zsh/newuser.zshrc.recommended" do
  mode "644"
end

# # elasticsearch
# #
# remote_file "/tmp/elasticsearch-0.19.9.deb" do
#   source "http://cloud.github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.19.9.deb"
#   mode 0644
#   checksum "1b75559db4e77f3ee92cac8a3e3e0f64c00adebb81977c16dcc883520a518b7b"
# end

# dpkg_package "elasticsearch" do
#   source "/tmp/elasticsearch-0.19.9.deb"
#   action :install
# end

# # graylog2
# #
# include_recipe "graylog2::server"
# include_recipe "graylog2::web_interface"
