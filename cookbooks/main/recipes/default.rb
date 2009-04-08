# uncomment if you want to run couchdb recipe
# require_recipe "couchdb"

# uncomment to turn your instance into an integrity CI server
#require_recipe "integrity"

execute 'stop-mysql' do
  command %Q{
    /etc/init.d/mysql stop
  }

  not_if "ps ax | grep mysqld | grep -v grep"
end

require_recipe "mbari-ruby"
require_recipe "monit"
require_recipe "haproxy"