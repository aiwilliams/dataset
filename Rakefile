# -*- ruby -*-

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'hoe'
require 'dataset/version'
require 'spec/rake/spectask'

Hoe.new('dataset', Dataset::VERSION::STRING) do |p|
  p.developer('Adam Williams', 'adam@thewilliams.ws')
end

task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end
