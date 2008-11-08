require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

require 'test/unit/testresult'

describe Test::Unit::TestCase do
  it 'should have a dataset method' do
    testcase = Class.new(Test::Unit::TestCase)
    testcase.should respond_to(:dataset)
  end
  
  it 'should accept multiple datasets' do
    load_count = 0
    dataset_one = Class.new(Dataset::Base) do
      define_method(:load) { load_count += 1 }
    end
    dataset_two = Class.new(Dataset::Base) do
      define_method(:load) { load_count += 1 }
    end
    testcase = Class.new(Test::Unit::TestCase) do
      dataset dataset_one, dataset_two
    end
    run_testcase(testcase)
    load_count.should be(2)
  end
  
  it 'should provide one dataset session for tests' do
    sessions = []
    testcase = Class.new(Test::Unit::TestCase) do
      dataset Class.new(Dataset::Base)
      
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
  
  it 'should forward blocks passed in to the dataset method' do
    load_count = 0
    testcase = Class.new(Test::Unit::TestCase) do
      dataset_class = Class.new(Dataset::Base)
      dataset dataset_class do
        load_count += 1
      end
    end
    
    run_testcase(testcase)
    load_count.should == 1
  end
  
  it 'should forward blocks passed in to the dataset method that do not use a dataset class' do
    load_count = 0
    testcase = Class.new(Test::Unit::TestCase) do
      dataset do
        load_count += 1
      end
    end
    
    run_testcase(testcase)
    load_count.should == 1
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