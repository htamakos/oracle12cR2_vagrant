#
# Cookbook Name:: docker_engine
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute 'yum-update' do
  user 'root'
  command 'yum -y update'
  action :run
end

cookbook_file '/etc/yum.repos.d/docker.repo' do
  source 'docker.repo'
  user 'root'
  mode '644'
end

package 'docker-engine'

execute 'chkconfig-docker' do
  command 'chkconfig docker on'
  action :run
end

service 'docker' do
  action [:start, :enable]
end

group 'docker' do
  action :create
end

node[:docker_users].each do |user_hash|
  execute 'usermod-docker' do
    command "usermod -aG docker #{user_hash}"
    action :run
  end
end

