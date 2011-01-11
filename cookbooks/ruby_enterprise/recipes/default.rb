#
# Cookbook Name:: ruby_enterprise
# Recipe:: default
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Sean Cribbs (<seancribbs@gmail.com>)
# Author:: Michael Hale (<mikehale@gmail.com>)
# 
# Copyright:: 2009-2010, Opscode, Inc.
# Copyright:: 2009, Sean Cribbs
# Copyright:: 2009, Michael Hale
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "build-essential"

if ( node[:platform] == 'ubuntu' )
  if ( node[:kernel][:machine] == 'x86_64' )
    kernel_machine = 'amd64'
  elsif ( node[:kernel][:machine] == 'i686' )
    kernel_machine = 'i386'
  else
    kernel_machine = 'i386'
  end

  remote_file "/tmp/ruby-enterprise_#{node[:ruby_enterprise][:version]}_#{kernel_machine}_#{node[:platform]}#{node[:platform_version]}.deb" do
    case node[:platform_version]
      when "8.04" then 
        if kernel_machine == "i386"
          dir_num = "71099"
        elsif kernel_machine == "amd64"
          dir_num = "71097"
        end
      when "10.04" then 
        if kernel_machine == "i386"
          dir_num = "71100"
        elsif kernel_machine == "amd64"
          dir_num = "71098"
        end
    end
    
    external_file = "http://rubyforge.org/frs/download.php/#{dir_num}/ruby-enterprise_#{node[:ruby_enterprise][:version]}_#{kernel_machine}_#{node[:platform]}#{node[:platform_version]}.deb"

    source external_file
  end
   
  bash "Install Ruby Enterprise Edition from deb" do
    cwd "/tmp"
    code <<-EOH
    dpkg -i ruby-enterprise_#{node[:ruby_enterprise][:version]}_#{kernel_machine}_#{node[:platform]}#{node[:platform_version]}.deb
    EOH
  end

  %w{apache2-prefork-dev libapr1-dev libaprutil1-dev}.each do |pkg|
    package pkg
  end

#  passenger_version = system("/usr/local/bin/passenger-config --version")
#  passenger_version = `/usr/local/bin/passenger-config --version`
#  puts "Passenger version: "+passenger_version
#  exit

#  execute "passenger-config" do
#    command "/usr/local/bin/passenger-config --version"
#    action :run
#  end

  passenger_version = '2.2.14'

  bash "Install custom Phusion Passenger module" do
    code <<-EOH
    /usr/local/bin/passenger-install-apache2-module --auto
    echo "LoadModule passenger_module /usr/local/lib/ruby/gems/1.8/gems/passenger-#{passenger_version}/ext/apache2/mod_passenger.so" > /etc/apache2/mods-available/passenger.load
    echo "PassengerRoot /usr/local/lib/ruby/gems/1.8/gems/passenger-#{passenger_version}" > /etc/apache2/mods-available/passenger.conf
    echo "PassengerRuby /usr/local/bin/ruby" >> /etc/apache2/mods-available/passenger.conf
    a2enmod passenger
    EOH

#    if do
#      ::File.exists?("/usr/local/bin/passenger-config")
#    end
  end

else

  %w{ libssl-dev libreadline5-dev }.each do |pkg|
    package pkg
  end

  remote_file "/tmp/ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz" do
    source "#{node[:ruby_enterprise][:url]}.tar.gz"
    not_if { ::File.exists?("/tmp/ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz") }
  end

  bash "Install Ruby Enterprise Edition" do
    cwd "/tmp"
    code <<-EOH
    tar zxf ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz
    ruby-enterprise-#{node[:ruby_enterprise][:version]}/installer \
      --auto=#{node[:ruby_enterprise][:install_path]} \
      --dont-install-useful-gems
    EOH
    not_if do
      ::File.exists?("#{node[:ruby_enterprise][:install_path]}/bin/ree-version") &&
      system("#{node[:ruby_enterprise][:install_path]}/bin/ree-version | grep -q '#{node[:ruby_enterprise][:version]}$'")
    end
  end

end
