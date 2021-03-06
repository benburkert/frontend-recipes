#
# Cookbook Name:: haproxy
# Recipe:: default
#

package "haproxy" do
  version "1.3.15.5"
end

template "/etc/haproxy.cfg" do
  owner 'app'
  group 'app'
  mode 0644
  source "haproxy.cfg.erb"
  variables(node[:haproxy])
end

execute 'add-haproxy-to-default-run-level' do
  command %Q{
    rc-update add haproxy default
  }

  not_if 'rc-status | grep haproxy'
end

execute 'restart-haproxy' do
  command %Q{
    /etc/init.d/haproxy restart
  }
end

remote_file "/etc/nginx/servers/mashtags.conf" do
  source "mashtags.conf"
  owner 'root'
  group 'root'
  mode 0644
end

execute 'restart-nginx' do
  command %Q{
    /etc/init.d/nginx restart
  }
end