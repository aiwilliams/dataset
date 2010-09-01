require 'rubygems'
require 'plugit'

PLUGIT_ROOT = File.expand_path(File.dirname(__FILE__))

Plugit.describe do |dataset|
  dataset.environments_root_path = "#{PLUGIT_ROOT}/environments"
  vendor_directory               = "#{PLUGIT_ROOT}/../vendor/plugins"
  
  dataset.environment :default, 'Released versions of Rails and RSpec' do |env|
    env.library :rails, :export => "git clone git://github.com/rails/rails.git" do |rails|
      rails.after_update { `git fetch origin 3-0-stable:3-0-stable; git checkout 3-0-stable` }
      rails.load_paths = %w{/active_support/lib /active_record/lib /actionpack/lib}
      rails.requires = %w{active_support active_record active_record/fixtures action_controller action_view}
    end
    env.library :rspec, :export => "git clone http://github.com/dchelimsky/rspec-rails.git" do |rspec|
      rspec.after_update { `git checkout -b rails3 && mkdir -p #{vendor_directory} && ln -nsf #{File.expand_path('.')} #{vendor_directory + '/rspec'}` }
      rspec.requires = %w{spec}
    end
    env.library :cucumber, :export => "git clone git://github.com/aslakhellesoy/cucumber.git" do |cukes|
      cukes.after_update { `git fetch origin master; git checkout v0.2.3.1` }
      cukes.requires = %w{cucumber}
    end
  end
end