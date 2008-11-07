require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

require 'test/unit/testresult'

class Test::Unit::TestCase
  def self.dataset(dataset)
    dataset_session.add_dataset(self, dataset)
  end
  
  def self.dataset_session
    @dataset_session ||= Dataset::Session.new(Dataset::Database::Base.new)
  end
  
  def dataset_session
    self.class.dataset_session
  end
end

class Test::Unit::TestSuite
  def run_with_dataset(result, &progress_block)
    first_test_in_suite = tests.first
    first_test_in_suite.dataset_session.load_datasets_for(first_test_in_suite.class)
    run_without_dataset(result, &progress_block)
  end
  alias run_without_dataset run
  alias run run_with_dataset
end

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