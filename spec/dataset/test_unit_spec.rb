require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

require 'test/unit/testresult'

describe Test::Unit::TestCase do
  it 'should have a dataset method' do
    testcase = Class.new(Test::Unit::TestCase)
    testcase.should respond_to(:dataset)
  end
  
  it 'should provide one dataset session for tests' do
    sessions = []
    testcase = Class.new(Test::Unit::TestCase) do
      dataset Class.new(Dataset::Base) {
        def load; end
      }
      
      define_method(:test_one) do
        sessions << dataset_session
      end
      define_method(:test_two) do
        sessions << dataset_session
      end
    end
    run_testcase(testcase)
    sessions.size.should be(2)
    sessions.uniq.size.should be(1)
  end
  
  it 'should load the dataset when the suite is run' do
    load_count = 0
    dataset = Class.new(Dataset::Base) do
      define_method(:load) do
        load_count += 1
      end
    end
    
    testcase = Class.new(Test::Unit::TestCase) do
      self.dataset(dataset)
      def test_one; end
      def test_two; end
    end
    
    run_testcase(testcase)
    load_count.should be(1)
  end
  
  def run_testcase(testcase)
    result = Test::Unit::TestResult.new
    testcase.suite.run(result) {}
    result.failure_count.should be(0)
    result.error_count.should be(0)
  end
end