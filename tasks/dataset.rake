namespace :db do
  namespace :dataset do
    desc "Load one or more datasets into the current environment's database using datasets=name,name"
    task :load => :environment do
      require 'dataset'
      dataset_names = ENV['datasets'] || 'default'
      context = Class.new do
        extend Dataset::ClassMethods
        datasets_directory ["#{RAILS_ROOT}/spec", "#{RAILS_ROOT}/test"].detect {|path| File.directory?(path)}
        add_dataset *dataset_names
        dataset_session.load_datasets_for self
      end
    end
  end
end