#
# Cookbook Name:: dnsmasq
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "dnsmasq" do
  action :install
end

template "/etc/dnsmasq.conf" do
  group "root"
  owner "root"
  mode  0644
end

service "dnsmasq" do
  supports :start => true, :stop => true, :restart => true
  action [:enable, :restart]
end

template "/etc/resolv.conf" do
  group "root"
  owner "root"
  mode  0644
end
