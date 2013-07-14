# coding:utf-8
#
# Cookbook Name:: iptables
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "iptables_nat_router" do
  user "root"
  code <<"EOS"
internal_ip='#{node[:iptables][:internal_ip]}'

my_internet_ip='#{node[:iptables][:my_internet_ip]}'
my_internal_ip='#{node[:iptables][:my_internal_ip]}'
lan=#{node[:iptables][:lan_eth]}
wan=#{node[:iptables][:wan_eth]}

# ルール全消去
iptables -F
iptables -t nat -F

# デフォルトポリシーの設定
#iptables -P INPUT DROP
#iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#iptables -P OUTPUT ACCEPT

#iptables -P FORWARD DROP
#iptables -A FORWARD -i $lan -o $wan -s $internal_ip -j ACCEPT
#iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

#loopback
#iptables -A INPUT -i lo -j ACCEPT
#iptables -A OUTPUT -o lo -j ACCEPT

#ICMP trusthost->myhost
#iptables -A INPUT -p icmp --icmp-type echo-request -s $trusthost -d $my_internal_ip -j ACCEPT
#iptables -A OUTPUT -p icmp --icmp-type echo-reply  -s $my_internal_ip -d $trusthost -j ACCEPT

#ICMP myhost->trusthost
#iptables -A OUTPUT -p icmp --icmp-type echo-request -s $my_internal_ip -d $trusthost -j ACCEPT
#iptables -A INPUT -p icmp --icmp-type echo-reply -s $trusthost -d $my_internal_ip -j ACCEPT

#ssh trusthost-> myhost
#iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
#iptables -A INPUT -p tcp -m state --state NEW,ESTABLISHED,RELATED -s $trusthost -d $my_internet_ip --dport 22 -j ACCEPT
#iptables -A OUTPUT -p tcp -s $my_internal_ip --sport 22 -d $trusthost -j ACCEPT

# SNAT
iptables -t nat -A POSTROUTING -o $wan -s $internal_ip -j MASQUERADE

#Outgoing packet should be real internet Address
iptables -A OUTPUT -o $wan -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -o $wan -d 176.16.0.0/12 -j DROP
iptables -A OUTPUT -o $wan -d 192.168.1.0/24 -j DROP
iptables -A OUTPUT -o $wan -d 127.0.0.0/8 -j DROP

iptables-save > /etc/iptables.rule

echo 1 > /proc/sys/net/ipv4/ip_forward
EOS
end

bash "/etc/sysctl.conf" do
  user "root"
  code <<"EOS"
sed -i -e "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
EOS
end

template "/etc/init.d/iptables" do
  group "root"
  owner "root"
  mode  0755
end

service "iptables" do
  supports :start => true, :stop => true
  action [:enable, :start]
end
