%w{
  gcc
  checkinstall
  libxml2-dev
  libxslt-dev
  sqlite3
  libsqlite3-dev
  libcurl4-openssl-dev
  libc6-dev
  libmysql++-dev
  libicu-dev
  redis-server
  openssh-server
  python-dev
  python-pip
}.each do |pkg|
  package pkg
end

group 'git'

user 'git' do
  comment 'Git'
  gid 'git'
  home '/home/git'
  shell '/bin/bash'
  system true
  supports :manage_home => true
end

user 'gitlab' do
  comment 'Git Lab'
  gid 'git'
  home '/home/gitlab'
  shell '/bin/false'
  supports :manage_home => true
end

bash 'create gitlab SSH key' do
  user 'root'
  cwd '/tmp'
  code "sudo -H -u gitlab ssh-keygen -q -N '' -t rsa -f /home/gitlab/.ssh/id_rsa"
  not_if 'test -f /home/gitlab/.ssh/id_rsa'
end

bash 'git clone gitolite' do
  user 'root'
  cwd '/home/git'
  code <<-EOS
sudo -H -u git git clone git://github.com/gitlabhq/gitolite /home/git/gitolite    
sudo -u git -i -H /home/git/gitolite/src/gl-system-install
sudo cp /home/gitlab/.ssh/id_rsa.pub /home/git/gitlab.pub
sudo chmod 777 /home/git/gitlab.pub

sudo -u git -H sed -i 's/0077/0007/g' /home/git/share/gitolite/conf/example.gitolite.rc
sudo -u git -H sh -c "PATH=/home/git/bin:$PATH; gl-setup -q /home/git/gitlab.pub"
sudo -u gitlab -H ssh-keyscan -H localhost >> /home/gitlab/.ssh/known_hosts
  EOS
  not_if 'test -d /home/git/gitolite'
end

bash 'fix permissions' do
  user 'root'
  code <<-EOS
sudo chmod -R g+rwX /home/git/repositories/
sudo chown -R git:git /home/git/repositories/
  EOS
end

bash 'install pygments' do
  user 'root'
  code 'pip install pygments'
  only_if '[ `pip freeze | grep -ci ^pygments` == 1 ]'
end

bash 'gitlabhq install' do
  user 'gitlab'
  cwd '/home/gitlab'
  code <<-EOS
git clone git://github.com/gitlabhq/gitlabhq.git gitlab
cd gitlab
cp config/gitlab.yml.example config/gitlab.yml
cp config/database.yml.sqlite config/database.yml
bundle install --without development test --deployment
bundle exec rake gitlab:app:setup RAILS_ENV=production
  EOS
  not_if 'test -d /home/gitlab/gitlab'
end