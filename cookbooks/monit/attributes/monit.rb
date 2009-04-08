monit Mash.new unless attribute?('monit')

monit[:application] = @attribute[:applications].keys.first
monit[:user]        = @attribute[:users].first[:username]
monit[:password]    = @attribute[:users].first[:password]