require_recipe "apt"
require_recipe "apache2"
require_recipe "mysql::libs"
require_recipe "mysql::server"

# PHP 5 -- normal 8.04
require_recipe "php::php5"
require_recipe "php::module_curl"
require_recipe "php::module_gd"
require_recipe "php::module_mcrypt"
require_recipe "php::module_mysql"
#require_recipe "php::module_memcache"
##require_recipe "php::module_sqlite3"
##require_recipe "sqlite"

# Ruby on Rails -- Returnity 8.04
require_recipe "ruby_enterprise"

# Ruby on Rails -- normal 10.04
#require_recipe "ruby"
#require_recipe "ruby::gems"
#require_recipe "ruby::rails"
#require_recipe "ruby::module_haml"
#require_recipe "ruby::module_mysql"

execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :restart, resources(:service => "apache2")
end

web_app "application" do
  template "application.conf.erb"
  notifies :restart, resources(:services => "apache2")
end
