Vagrant.configure(2) do |config|
  config.vm.box = "puphpet/ubuntu1604-x64"

  config.vm.network :private_network, ip: "172.10.0.123", :netmask => "255.255.0.0"

  config.vm.provision "shell", path: "_provision/script.sh"

  # If you have the vagrant triggers plugin installed, uncomment this to remind you of the IP on 'up'
  # config.trigger.after [:up, :resume, :reload] do
  #     info "IP: 172.10.0.36"
  # end

end
