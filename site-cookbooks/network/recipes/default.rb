#
# Cookbook Name:: network
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/etc/hostname" do
  group "root"
  owner "root"
  mode  0644
end

r_hostname = Regexp.new(node[:network][:hostname])
if r_hostname =~ `hostname`
else
  bash "hostname" do
    user "root"
    code <<"EOS"
hostname #{node[:network][:hostname]}
EOS
  end
end

template "/etc/hosts" do
  group "root"
  owner "root"
  mode  0644
end

template "/etc/network/interfaces" do
  group "root"
  owner "root"
  mode  0644
end

if node[:network][:router]
  template "/etc/resolv.conf" do
    group "root"
    owner "root"
    mode  0644
  end
end

service "networking" do
  supports :start => true, :stop => true, :reload => true, :restart => true
  action [:enable, :restart]
end
