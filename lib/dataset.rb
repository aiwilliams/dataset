require 'dataset/base'
require 'dataset/database/base'
require 'dataset/database/mysql'
require 'dataset/database/sqlite3'
require 'dataset/collection'
require 'dataset/load'
require 'dataset/resolver'
require 'dataset/session'
require 'dataset/session_binding'
require 'dataset/record/meta'
require 'dataset/record/fixture'
require 'dataset/record/model'

module Dataset
  def self.included(test_context)
    if test_context.name =~ /TestCase\Z/
      require 'dataset/extensions/test_unit'
    elsif test_context.name =~ /ExampleGroup\Z/
      require 'dataset/extensions/rspec'
    else
      raise "I don't understand your test framework"
    end
    
    test_context.extend ClassMethods
  end
  
  module ClassMethods
    def self.extended(context_class)
      context_class.module_eval do
        include InstanceMethods
        superclass_delegating_accessor :dataset_session
      end
    end
    
    mattr_accessor :datasets_database_dump_path
    self.datasets_database_dump_path = File.expand_path(RAILS_ROOT + '/tmp/dataset') if defined?(RAILS_ROOT)
    
    # Replaces the default Dataset::Resolver with one that will look for
    # dataset class definitions in the specified directory. Snapshots of the
    # database will be stored in a subdirectory 'tmp'.
    def datasets_directory(path)
      Dataset::Resolver.default = Dataset::DirectoryResolver.new(path)
      Dataset::ClassMethods.datasets_database_dump_path = File.join(path, '/tmp/dataset')
    end
    
    def add_dataset(*datasets, &block)
      dataset_session = dataset_session_in_hierarchy
      datasets.each { |dataset| dataset_session.add_dataset(self, dataset) }
      dataset_session.add_dataset(self, Class.new(Dataset::Block) {
        define_method :doload, block
      }) unless block.nil?
    end
    
    def dataset_session_in_hierarchy
      self.dataset_session ||= begin
        database_spec = ActiveRecord::Base.configurations['test'].with_indifferent_access
        database_class = Dataset::Database.const_get(database_spec[:adapter].classify)
        database = database_class.new(database_spec, Dataset::ClassMethods.datasets_database_dump_path)
        Dataset::Session.new(database)
      end
    end
  end
  
  module InstanceMethods
    def extend_from_dataset_load(load)
      load.dataset_binding.block_variables.each do |k,v|
        instance_variable_set(k, v)
      end
      self.extend load.dataset_binding.record_methods
      self.extend load.dataset_binding.model_finders
      self.extend load.helper_methods
    end
  end
end