Padrino.configure_apps do
  # enable :sessions
  set :session_secret, 'e4c14cf23ec99a1813d94693140e586cb72a4788954aa6a3f78feffd6334e4cb'
  set :protection, :except => :path_traversal
  set :protect_from_csrf, true
end

if k = ENV['POSTMARK_KEY']
  POSTMARK_KEY = k
else
  require_relative 'credentials.rb'
end

require_relative 'deadline.rb'


# Mounts the core application for this project

Padrino.mount("UncCarpool::Admin", :app_file => Padrino.root('admin/app.rb')).to("/admin")
Padrino.mount('UncCarpool::App', :app_file => Padrino.root('app/app.rb')).to('/')
