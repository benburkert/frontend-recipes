#
# Cookbook Name:: postgresql
# Recipe:: default
#

directory "/db/postgresql" do
  owner "postgres"
  group "postgres"
  mode 0755
  recursive false
end

directory "/db/postgresql/data" do
  owner "postgres"
  group "postgres"
  mode 0700
  recursive false
end

template "/etc/conf.d/postgresql-8.3" do
  owner 'root'
  group 'root'
  mode 0644
  source "postgresql-8.3.erb"
  variables :basedir  => '/db/postgresql',
            :user     => 'postgres',
            :group    => 'postgres'
end

execute 'init-postgres-database' do
  command %Q{
    su - postgres -c "initdb --locale=en_US.UTF-8 -E=UNICODE /db/postgresql/data"
  }

  not_if { not Dir["/db/postgresql/data/*"].empty? }
end

execute 'add-postgresql-to-default-run-level' do
  command %Q{
    rc-update add postgresql-8.3 default
  }

  not_if 'rc-status | grep postgresql-8.3'
end

execute 'ensure-postgresql-is-running' do
  command %Q{
    /etc/init.d/postgresql-8.3 restart
  }
  not_if "/etc/init.d/postgresql-8.3 status | grep 'status:  started'"
end

execute 'add-database-user' do
  command %Q{
    su - postgres -c "createuser -S -D -R -l -i -E #{node[:owner_name]}"
    su - postgres -c "psql -c \\"ALTER USER #{node[:owner_name]} WITH ENCRYPTED PASSWORD '#{node[:owner_pass]}'\\""
  }

  not_if "su - postgres -c \"psql -c\\\"SELECT * FROM pg_roles\\\"\" | grep #{node[:owner_name]}"
end

node[:applications].each_key do |appname|
  execute "add-#{appname}-database" do
    command %Q{
      su - postgres -c "createdb -E=UTF8 -O #{node[:owner_name]} #{appname}_#{node[:environment][:role]}"
    }

    not_if "su - postgres -c \"psql -c \\\"SELECT * FROM pg_database\\\"\" | grep #{appname}_#{node[:environment][:role]}"
  end
end