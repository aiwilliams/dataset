$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/vendor/plugins/rspec/lib'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

desc "Generate rdoc"
Rake::RDocTask.new(:doc) do |r|
  r.title = "Dataset"
  r.main = "README"
  r.options << "--line-numbers"
  r.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
  r.rdoc_dir = "doc"
end

task :default => :spec