module Dataset
  class TestSuite
    def initialize(suite, test_class)
      @suite = suite
      @test_class = test_class
    end
    
    def run(result, &progress_block)
      @test_class.dataset_session.load_datasets_for(@test_class)
      @suite.run(result, &progress_block)
    end
    
    def method_missing(method_symbol, *args)
      @suite.send(method_symbol, *args)
    end
  end
end

class Test::Unit::TestCase
  def self.dataset(dataset)
    dataset_session.add_dataset(self, dataset)
  end
  
  def self.dataset_session
    @dataset_session ||= Dataset::Session.new(Dataset::Database::Base.new)
  end
  
  class << self
    def suite_with_dataset
      Dataset::TestSuite.new(suite_without_dataset, self)
    end
    alias suite_without_dataset suite
    alias suite suite_with_dataset
  end
end