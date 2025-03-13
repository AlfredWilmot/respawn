# VM networking
Notes relevant to netowrking VMs.

## File-transfer between VMs and hosts on a public network

`Vagrant` requires a `NAT` over `eth0` to interact with its VMs,
however additional bridged adatpers can be configured for transferring files over local networks.

Assuming the network in question supports `DHCP`, and your host machine is connected to that network,
then only the following additional line in your `Vagrantfile` is requred:
```ruby
config.vm.network "public_network"
# (https://developer.hashicorp.com/vagrant/docs/networking/public_network)
```
