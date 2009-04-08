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

execute "uninstall-all-fastthreads" do
  command %Q{
    gem uninstall fastthread -f
  }

  not_if "gem list fastthread | grep 'fastthread'"
end

execute "install-fastthread-1.0.1" do
  command %Q{
    gem install fastthread --version=1.0.1
  }
end

execute "export-nuke_merb" do
  command %Q{
    echo "alias nuke_merb=\"ps auxww | grep \\\"merb\\\" | grep -v \\\"grep\\\" | awk '{print \\$2}' | xargs kill -9\"" > ~/.bashrc
  }
  not_if "cat ~/.bashrc | grep 'nuke_merb'"
end

require_recipe "mbari-ruby"
require_recipe "haproxy"
require_recipe "monit"