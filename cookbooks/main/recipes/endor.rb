include_recipe "build-essential"

# base packages
#
%w{
  libxml2-dev
  libxslt-dev
  apt-src
  libcurl4-openssl-dev
  imagemagick
  mailutils
  zlib1g
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
  htop
}.each do |pkg|
  package pkg
end

# apps user/ group
#
group 'apps'

user 'apps' do
  comment 'Application User'
  gid 'apps'
  home '/home/apps'
  shell '/usr/bin/zsh'
  system true
  supports :manage_home => true
end

# ack
#
bash 'setup ack alternative' do
  user 'root'
  cwd '/tmp'
  code 'update-alternatives --install /usr/bin/ack ack /usr/bin/ack-grep 0'
end

# locales
#
bash 'set locale to AU' do
  user 'root'
  cwd '/tmp'
  code <<-EOS
cat > /etc/default/locale << EOSS
LANG='en_AU.UTF-8'
LANGUAGE='en_AU:en'
EOSS
locale-gen en_AU > /dev/null 2>&1
locale-gen en_AU.UTF-8 > /dev/null 2>&1
dpkg-reconfigure locales > /dev/null 2>&1
  EOS
end

# monit
#
include_recipe "monit"

# varnish
#
include_recipe "varnish"

monitrc "varnish"

# nginx
#
[ '/etc/nginx/sites-available', '/etc/nginx/sites-enabled' ].each do |d|
  directory d do
    owner "apps"
    group "apps"
    mode "2755"
  end

  Dir["#{d}/*"].each do |f|
    file f do
      owner "apps"
      group "apps"
      mode "0644"
    end
  end
end

unless File.exist?(node[:nginx][:binary])
  node.set[:nginx][:configure_flags] = [
    "--prefix=#{node[:nginx][:source][:prefix]}",
    "--conf-path=#{node[:nginx][:dir]}/nginx.conf"
  ]
  include_recipe 'nginx::source'
end

link "#{node[:nginx][:source][:base]}" do
  to "#{node[:nginx][:source][:base]}-#{node[:nginx][:version]}"
end

monitrc "nginx"

# mongo
#
execute "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10" do
  not_if 'apt-key list | grep "7F0CEB10"'
end

apt_repository "mongodb" do
  uri "http://downloads-distro.mongodb.org/repo/ubuntu-upstart"
  distribution "dist"
  components ["10gen"]
  action :add
end

package "mongodb-10gen"

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

# redis
#
execute "apt-key adv --keyserver keyserver.ubuntu.com --recv 5862E31D" do
  not_if 'apt-key list | grep "5862E31D"'
end

apt_repository "redis" do
  uri "http://ppa.launchpad.net/rwky/redis/ubuntu"
  distribution "precise"
  components ["main"]
  action :add
end

package "redis-server"

# ruby
#
bash "ruby #{node[:ruby][:version]}" do
  user 'root'
  cwd '/tmp'
  code <<-EOS
  wget -c http://mirrors.ibiblio.org/ruby/ruby-#{node[:ruby][:version]}.tar.gz
  tar xzf ruby-#{node[:ruby][:version]}.tar.gz
  cd ruby-#{node[:ruby][:version]}
  ./configure --prefix=/opt/ruby-#{node[:ruby][:version]} && make && make install
  EOS
  not_if { File.exists?("/opt/ruby/bin/ruby") }
end

bash 'ensure ruby permissions are good' do
  user 'root'
  cwd '/tmp'
  code <<-EOS
chown -R root:sudo /opt/ruby*
chmod -R g=u /opt/ruby*
  EOS
end

cookbook_file "/etc/profile.d/ruby.sh" do
  source "ruby.sh"
  mode "0644"
end

link "/opt/ruby" do
  to "/opt/ruby-#{node[:ruby][:version]}"
end

gem_package 'bundler' do
  gem_binary '/opt/ruby/bin/gem'
end

# rsnapshot
#
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

# zsh
#
directory "/etc/zsh/functions" do
  owner "root"
  group "root"
  mode "755"
end

cookbook_file "/etc/zsh/zshenv" do
  mode "644"
end

link "/etc/zsh/zlogin" do
  to "/etc/zsh/zshenv"
end

{
  :git_cwd_info => 644,
  :ruby_current_version => 644

}.each do |file, perms|
  cookbook_file "/etc/zsh/functions/#{file}" do
    mode "#{perms}"
  end
end

cookbook_file "/etc/zsh/newuser.zshrc.recommended" do
  mode "644"
end
