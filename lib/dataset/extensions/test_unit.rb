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
        @suite.tests.each { |e| e.extend_from_dataset_load(load) }
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
      add_dataset(*datasets, &block)
      
      # Unfortunately, if we have rspec loaded, TestCase has it's suite method
      # modified for the test/unit runners, but uses a different mechanism to
      # collect tests if the rspec runners are used.
      if included_modules.find {|m| m.name =~ /ExampleMethods\Z/}
        load = nil
        before(:all) do
          load = dataset_session.load_datasets_for(self.class)
          extend_from_dataset_load(load)
        end
        before(:each) do
          extend_from_dataset_load(load)
        end
      end
    end
  end
end