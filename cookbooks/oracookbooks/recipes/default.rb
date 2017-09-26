# install dependent packages
node[:oracle][:deps_lib].each do |deps|
  yum_package deps
end

# create inventory group
group node[:oracle][:inventory_group][:name] do
  action :create
  gid node[:oracle][:inventory_group][:gid]
  append true
end

# create oracle user
user node[:oracle][:user][:name] do
  action :create
  gid   node[:oracle][:user][:gid]
  shell node[:oracle][:user][:shell]
  home  node[:oracle][:user][:home]
end

# change oracle user password
execute 'change_user_password' do
  command "echo #{node[:oracle][:user][:password]} | passwd #{node[:oracle][:user][:name]} --stdin"
end

# create oracle user home directory
directory node[:oracle][:user][:home] do
  action :create
  owner node[:oracle][:user][:name]
  group node[:oracle][:inventory_group][:name]
  mode node[:oracle][:inventory_group][:mode]
end

# create zshrc
template "#{node[:oracle][:user][:home]}/.zshenv" do
  action :create
  source 'zshenv.erb'
end

# create necessary groups and add oracle user to these groups as a member
node[:oracle][:user][:subgroups].each_key do |key|
  group key do
    gid node[:oracle][:user][:subgroups][key]
    members [node[:oracle][:user][:name]]
    append true
  end
end

# create resource sstricted file which are related to oracle user.
cookbook_file "/etc/security/limits.d/#{node[:oracle][:user][:name]}.conf" do
  source 'limit_conf'
end

# change kernel parameter settings
cookbook_file "/etc/sysctl.conf" do
  source 'kernel_param'
end

# create oracle database home directory and install_dir
[
  node[:oracle][:database][:home],
  node[:oracle][:database][:install_dir],
  node[:oracle][:inventory][:dir]
].each do |dir|
  directory dir do
    group  node[:oracle][:inventory_group][:name]
    mode   node[:oracle][:database][:mode]
    owner  node[:oracle][:user][:name]
    recursive   true
  end
end

execute "change_permission_oracle_directory" do
  command "chown -R #{user node[:oracle][:user][:name]}:#{node[:oracle][:inventory_group][:name]} #{node[:oracle][:base]}"
  user 'root'
end

template '/etc/oraInst.loc' do
  action :create
  source 'oraInst_loc.erb'
end

yum_package 'unzip'

execute 'move-oracle-binary' do
  command "cp /vagrant/linuxx64_12201_database* #{node[:oracle][:database][:install_dir]}/"
  not_if { File.exist?("#{node[:oracle][:database][:install_dir]}/database/welcome.html") }
end

unless File.exist?("#{node[:oracle][:database][:install_dir]}/database/welcome.html")
  node[:oracle][:database][:zips].each do |zip_file|
    zip_path = "#{node[:oracle][:database][:install_dir]}/#{zip_file}"
    #execute "install_#{zip_file}" do
    #  command "wget node[:oracle][:database][:wget_url] -o zip_path"
    #  not_if "test -f #{zip_path}"
    #end

    execute "unzip_#{zip_file}" do
      command "unzip #{zip_path} -d #{node[:oracle][:database][:install_dir]}"
      user node[:oracle][:user][:name]
      group node[:oracle][:inventory_group][:name]
    end
  end
end

template "#{node[:oracle][:database][:install_dir]}/database/response/db_install.rsp" do
  action :create
  user    node[:oracle][:user][:name]
  group   node[:oracle][:inventory_group][:name]
  source "db_install_rsp.erb"
end

template "#{node[:oracle][:database][:install_dir]}/database/response/dbca.rsp" do
  action :create
  user    node[:oracle][:user][:name]
  group   node[:oracle][:inventory_group][:name]
  source "dbca_rsp.erb"
end

if node[:oracle][:install_oracle_software]
  execute "install_oracle_software" do
    command "su #{node[:oracle][:user][:name]} -l -c '#{node[:oracle][:database][:install_dir]}/database/runInstaller -silent -responseFile #{node[:oracle][:database][:install_dir]}/database/response/db_install.rsp -force -waitforcompletion -ignoreSysPrereqs'"
    cwd     "#{node[:oracle][:database][:install_dir]}/database"
    returns [0,6]
  end

  execute "root_sh_script" do
    command "#{node[:oracle][:database][:home]}/root.sh"
  end

  execute 'create_database' do
    command "su #{node[:oracle][:user][:name]} -l -c '#{node[:oracle][:database][:home]}/bin/dbca -silent -createDatabase -responseFile #{node[:oracle][:database][:install_dir]}/database/response/dbca.rsp'"
  end
end

yum_package 'readline-devel'

git '/usr/local/src/rlwrap' do
  repository node[:rlwrap][:repository]
  reference 'master'
  action :sync
end

yum_package 'automake'
yum_package 'libtool'

execute 'install adtup rlwrap' do
  command 'autoreconf -i && ./configure && make && make install'
  cwd     '/usr/local/src/rlwrap'
  not_if  'which rlwrap'
end
