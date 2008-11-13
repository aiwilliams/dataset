module Dataset
  class TestSuite
    def initialize(suite, test_class)
      @suite = suite
      @test_class = test_class
    end
    
    def dataset_session
      @test_class.dataset_session
    end
    
    def run(result, &progress_block)
      if dataset_session
        load = dataset_session.load_datasets_for(@test_class)
        @suite.tests.each do |test_instance|
          test_instance.extend load.dataset_binding.instance_loaders
          test_instance.extend load.helper_methods
        end
      end
      @suite.run(result, &progress_block)
    end
    
    def method_missing(method_symbol, *args)
      @suite.send(method_symbol, *args)
    end
  end
end

class Test::Unit::TestCase
  superclass_delegating_accessor :dataset_session
  
  class << self
    def suite_with_dataset
      Dataset::TestSuite.new(suite_without_dataset, self)
    end
    alias_method_chain :suite, :dataset
    
    def dataset(*datasets, &block)
      dataset_session = dataset_session_in_hierarchy
      datasets.each { |dataset| dataset_session.add_dataset(self, dataset) }
      dataset_session.add_dataset(self, Class.new(Dataset::Base) {
        define_method :load, block
      }) unless block.nil?
    end
    
    def dataset_session_in_hierarchy
      self.dataset_session ||= begin
        database_spec = ActiveRecord::Base.configurations['test'].with_indifferent_access
        database_class = Dataset::Database.const_get(database_spec[:adapter].classify)
        database = database_class.new(database_spec, File.expand_path(RAILS_ROOT + '/spec/tmp'))
        Dataset::Session.new(database)
      end
    end
  end
end