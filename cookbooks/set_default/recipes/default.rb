#
# Cookbook Name:: set_proxy
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

template '/etc/sysconfig/docker' do
  source 'sysconfig_docker.erb'
end

file '/etc/motd' do
  action :create_if_missing
  mode   '644'
  owner  node[:login_user]
  group  node[:login_user]
end

yum_package 'git'

git '/opt/screenfetch' do
  repository node['screenfetch'][:repository]
  reference 'master'
  action :sync
end

execute 'ln_screenfetch' do
  command 'cp /opt/screenfetch/screenfetch-dev /usr/local/bin/screenfetch -f'
  only_if { File.exist?('/opt/screenfetch/screenfetch-dev') && !File.exist?('/usr/local/bin/screenfetch') }
end

execute 'screenfetch' do
  command 'screenfetch > /etc/motd'
end

yum_package 'zsh'
yum_package 'finger'

node['oh_my_zsh']['users'].each do |user_hash|
  user_hash_home = user_hash == 'root' ? '/root' : "/home/#{user_hash}"

  execute 'change-shell-to-zsh' do
    #only_if "test $(finger #{user_hash} | grep Shell | awk '{ print $4 }') != '/bin/zsh'"
    command "chsh -s /bin/zsh #{user_hash}"
  end

  git "#{user_hash_home}/.oh-my-zsh" do
    repository node['oh_my_zsh'][:repository]
    user       user_hash
    reference  'master'
    action     :sync
  end

  template "#{user_hash_home}/.zshrc" do
    source   'zshrc.erb'
    owner    user_hash
    mode     '644'
    action   :create_if_missing
  end

end
