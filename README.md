Simple Order Protocol (sop). An imaginary protocol.
========

# About SOP

This is a simple, text protocol for an imaginary stock exchange. I created it for my [blog](https://prontog.wordpress.com/).

All message types follow the format HEADER|PAYLOAD|TRAILER (note that '|' is not included in the protocol).

The HEADER is very simple:

Field | Length | Type | Description
-----|---------|------|------
SOH | 1 | STRING | Start of header.
LEN | 3 | NUMERIC |Length of the payload (i.e. no header/trailer).

The TRAILER is even simpler:

Field | Length | Type | Description
-----|---------|------|------
ETX | 1 | STRING | End of text.

The message types are:

Type | Description | Payload Spec
-----|-------------|-----------
NO | New Order | [NO.csv](specs/NO.csv)
OC | Order Confirmation | [OC.csv](specs/OC.csv)
TR | Trade | [TR.csv](specs/TR.csv)
RJ | Rejection | [RJ.csv](specs/RJ.csv)
EN | Exchange News | [EN.csv](specs/EN.csv)
BO | Best Bid and Offer | [BO.csv](specs/BO.csv)
LO | Lough Out Loud (experimental) | [LO.csv](specs/LO.csv)

The [specs](specs) dir contains the specification for each message type in CSV format.

# Trying it out

First, clone this repo:
```bash
$ git clone https://github.com/prontog/SOP
$ cd SOP
```

## Vagrant preparation

The easiest way to try out this repo, is using *Vagrant* with *VirtualBox*. Skip this part if you already have them installed. Otherwise

1. Install [VirtualBox](https://www.virtualbox.org/). Make sure that *VBoxManage* is in the PATH.
1. Install [Vagrant](https://www.vagrantup.com/). Make sure that *vagrant* is in the PATH.
1. Install the following vagrant plugins:
	1. vagrant-hostmanager
	1. vagrant-vbguest
	1. vagrant-cachier
	1. vagrant-share
    1. vagrant-proxyconf (if you are behind a proxy)

See `vagrant --help` for more info on installing plugins. Also note that the HTTP_PROXY and HTTPS_PROXY env vars should be set if you are behind a proxy.

If you need to set a specific *IP* and/or you are behind a proxy, you can create the file *Vagrantfile.local* and setup the `config.vm.network` and `config.proxy` settings. You can also add extra "synced folders" of you wish. For example:

```ruby
config.vm.network "private_network", ip: "192.168.56.7"

config.proxy.http     = "http://192.168.56.1:9928"
config.proxy.https    = "http://192.168.56.1:9928"
config.proxy.no_proxy = "localhost,127.0.0.1"

config.vm.synced_folder "~/data", "/home/ubuntu/data", type: "virtualbox"
```

## Starting up the Vagrant box

1. `vagrant up`  to start the box. Note that the first time you run this command, it will take a few minutes to download and provision the box.
1. `vagrant ssh` to ssh into the box.

## Shutting down the Vagrant box

1. `exit` to logout from the box.
1. `vagrant halt` to shutdown the box.
