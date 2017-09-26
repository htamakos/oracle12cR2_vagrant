default[:login_user] = 'vagrant'
default[:login_user_home_dir] = "/home/#{default[:login_user]}"

default['screenfetch'][:repository] = 'https://github.com/KittyKatt/screenFetch.git'

default['oh_my_zsh']['users'] = ['root', 'vagrant', 'oracle']
default['oh_my_zsh'][:repository] = "https://github.com/robbyrussell/oh-my-zsh.git"
default['oh_my_zsh'][:plugins] = %w(git)
default['oh_my_zsh'][:theme] = "tjkirch"
default[:oracle][:base] = '/u01/app/oracle'
default[:oracle][:database][:home] = "#{default[:oracle][:base]}/product/12.1.0/dbhome_1"
default[:oracle][:database][:sid] = 'orcl'
