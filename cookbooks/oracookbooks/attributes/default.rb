default[:oracle][:user][:name] = 'oracle'
default[:oracle][:user][:password] = 'oracle'
default[:oracle][:user][:gid] = 54321
default[:oracle][:user][:shell] = '/bin/bash'
default[:oracle][:user][:home] = "/home/#{default[:oracle][:user][:name]}"
default[:oracle][:user][:subgroups] = {
  'dba'       => 54322,
  'oper'      => 54323,
  'backupdba' => 54324,
  'dgdba'     => 54325,
  'kmdba'     => 54326,
  'asmdba'    => 54327,
  'asmoper'   => 54328,
  'asmadmin'  => 54329,
  'racdba'    => 54330
}

default[:oracle][:inventory_group][:name] = 'oinstall'
default[:oracle][:inventory_group][:gid] = default[:oracle][:user][:gid]
default[:oracle][:inventory_group][:mode] = '0755'
default[:oracle][:inventory][:dir] = '/u01/app/oraInventory'

default[:oracle][:install_oracle_software] = false
default[:oracle][:base] = '/u01/app/oracle'
default[:oracle][:database][:home] = "#{default[:oracle][:base]}/product/12.2.0/dbhome_1"
default[:oracle][:database][:sid] = 'cdb'
default[:oracle][:database][:install_dir] = "#{default[:oracle][:base]}/install_dir"
default[:oracle][:database][:wget_url] = "https://example.com"
default[:oracle][:database][:zips] = ['linuxx64_12201_database.zip']
default[:oracle][:database][:password] = 'Welcome#1'
default[:oracle][:deps_lib] = [
  'binutils',
  'compat-libcap1',
  'compat-libstdc++-33',
  'gcc',
  'gcc-c++',
  'glibc',
  'glibc-devel',
  'ksh',
  'libaio',
  'libaio-devel',
  'libgcc',
  'libstdc++',
  'libstdc++-devel',
  'libXi',
  'libXtst',
  'make',
  'sysstat'
]

default[:rlwrap][:repository] = 'https://github.com/hanslub42/rlwrap.git'

