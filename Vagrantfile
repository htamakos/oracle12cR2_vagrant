# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  ENV['SET_PROXY'] = 'true'
  # box名の指定
  config.vm.box = 'oraclelinux68'

  # insecureなvagrantデフォルトのssh鍵の差替をやめさせる
  config.ssh.insert_key = false

  # boot時間のしきい値
  config.vm.boot_timeout = 100

  # proxyの設定
  ## vagrant up時のみしか適用されない
  if ENV['SET_PROXY']
    env_http_proxy = ENV['http_proxy']
    puts "set proxy: #{env_http_proxy}"
   
    config.proxy.http = env_http_proxy
    config.proxy.https = env_http_proxy 
    config.proxy.no_proxy = 'localhost,127.0.0.1,.example.com'
  else
    config.proxy.http = ''
    config.proxy.https = ''
  end

  config.vm.define('ml_node') do |node|
    # hostnameの指定
    node.vm.hostname = 'mlnode'

    node.vm.network :private_network, ip: '192.168.56.112'
    node.vm.network 'forwarded_port', guest: 8181, host: 8182

    node.ssh.username = 'vagrant'
    #node.vm.synced_folder('./work', '/home/oracle/work')

    # Vbguestの自動アップデートをやめる
    #node.vbguest.auto_update = false

    # プロビジョニング
    node.vm.provision 'chef_zero' do |chef|
      chef.cookbooks_path = 'cookbooks'
      chef.nodes_path = 'cookbooks'
    
      http_proxy = ENV['SET_PROXY'] ? ENV['http_proxy'] : ''

      chef.json = {
        http_proxy: http_proxy,
        oracle: { install_oracle_software: true }  
      }

      chef.run_list = [
        #'recipe[set_default::default]',
        #'recipe[docker_engine::default]',
        'recipe[oracookbooks::default]'
      ]
    end

    # virtualbox固有の設定
    node.vm.provider(:virtualbox) do |vb|

      ## 仮想マシンの名前設定
      vb.name = 'oraclelinux68_ml_node'

      ## GUIが立ち上がらないようにする
      vb.gui = false
      
      hdd = 'hdd01.vdi'
      unless File.exist?(hdd)
         vb.customize ['createhd', '--filename', hdd, '--size', 40*1024]
      end
      
      vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', 
                    '--port', 1, '--device', 0, '--type', 'hdd', '--medium', hdd]
    end
  end
end
