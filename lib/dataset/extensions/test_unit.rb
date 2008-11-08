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
  class << self
    def suite_with_dataset
      Dataset::TestSuite.new(suite_without_dataset, self)
    end
    alias_method_chain :suite, :dataset
    
    def dataset(*datasets, &block)
      @dataset_session ||= Dataset::Session.new(Dataset::Database::Base.new)
      datasets.each { |dataset| @dataset_session.add_dataset(self, dataset) }
      @dataset_session.add_dataset(self, Class.new(Dataset::Base) {
        define_method :load, block
      }) unless block.nil?
    end
    
    def dataset_session
      @dataset_session
    end
  end
  
  def dataset_session
    self.class.dataset_session
  end
end