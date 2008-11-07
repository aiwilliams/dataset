require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

TestCaseRoot = Class.new(Test::Unit::TestCase)
TestCaseChild = Class.new(TestCaseRoot)
TestCaseGrandchild = Class.new(TestCaseChild)

DatasetOne = Class.new(Dataset::Base)
DatasetTwo = Class.new(Dataset::Base)

describe Dataset::Session do
  before do
    @database = Dataset::Database::Sqlite3.new(SQLITE_DATABASE, "#{SPEC_ROOT}/tmp")
    @session = Dataset::Session.new(@database)
  end
  
  describe 'dataset associations' do
    it 'should allow the addition of datasets for a test' do
      @session.add_dataset TestCaseRoot, DatasetOne
      @session.datasets_for(TestCaseRoot).should == [DatasetOne]
      
      @session.add_dataset TestCaseRoot, DatasetTwo
      @session.datasets_for(TestCaseRoot).should == [DatasetOne, DatasetTwo]
      
      @session.add_dataset TestCaseRoot, DatasetOne
      @session.datasets_for(TestCaseRoot).should == [DatasetOne, DatasetTwo]
    end
    
    it 'should combine datasets from test superclasses into subclasses' do
      @session.add_dataset TestCaseRoot, DatasetOne
      @session.add_dataset TestCaseChild, DatasetTwo
      @session.add_dataset TestCaseChild, DatasetOne
      @session.datasets_for(TestCaseChild).should == [DatasetOne, DatasetTwo]
      @session.datasets_for(TestCaseGrandchild).should == [DatasetOne, DatasetTwo]
    end
  end
  
  describe 'dataset loading' do
    it 'should happen in the order declared' do
      load_order = []
      
      dataset_one = Class.new(Dataset::Base) {
        define_method :load do
          load_order << self.class
        end
      }
      dataset_two = Class.new(Dataset::Base) {
        define_method :load do
          load_order << self.class
        end
      }
      
      @session.add_dataset TestCaseRoot, dataset_two
      @session.add_dataset TestCaseRoot, dataset_one
      @session.load_datasets_for TestCaseRoot
      load_order.should == [dataset_two, dataset_one]
    end
    
    it 'should happen only once per test in a hierarchy' do
      load_count = 0
      
      dataset = Class.new(Dataset::Base) {
        define_method :load do
          load_count += 1
        end
      }
      
      @session.add_dataset TestCaseRoot, dataset
      @session.load_datasets_for TestCaseRoot
      load_count.should == 1
      
      @session.load_datasets_for TestCaseRoot
      load_count.should == 1
      
      @session.load_datasets_for TestCaseChild
      load_count.should == 1
    end
    
    it 'should capture the existing data before loading a superset, restoring the subset before a peer runs' do
      dataset_one_load_count = 0
      dataset_one = Class.new(Dataset::Base) do
        define_method :load do
          dataset_one_load_count += 1
          Thing.create!
        end
      end
      
      dataset_two_load_count = 0
      dataset_two = Class.new(Dataset::Base) do
        define_method :load do
          dataset_two_load_count += 1
          Place.create!
        end
      end
      
      @session.add_dataset TestCaseRoot, dataset_one
      @session.add_dataset TestCaseChild, dataset_two
      
      @session.load_datasets_for TestCaseRoot
      dataset_one_load_count.should == 1
      dataset_two_load_count.should == 0
      Thing.count.should == 1
      Place.count.should == 0
      
      @session.load_datasets_for TestCaseChild
      dataset_one_load_count.should == 1
      dataset_two_load_count.should == 1
      Thing.count.should == 1
      Place.count.should == 1
      
      @session.load_datasets_for TestCaseRoot
      dataset_one_load_count.should == 1
      dataset_two_load_count.should == 1
      Thing.count.should == 1
      Place.count.should == 0
    end
    
    it 'should be created for each dataset load, wrapping the outer scope' do
      pending
      test_subclass_peer = Class.new(TestCaseRoot)
      
      scope_one   = stub(Dataset::SessionBinding, :parent_scope => nil)
      scope_two   = stub(Dataset::SessionBinding, :parent_scope => scope_one)
      scope_three = stub(Dataset::SessionBinding, :parent_scope => scope_one)
      
      @session.should_receive(:new_scope).with(@database).and_return scope_one
      @session.should_receive(:new_scope).with(scope_one).and_return scope_two
      @session.should_receive(:new_scope).with(scope_one).and_return scope_three
      
      dataset_one = Class.new(Dataset::Base) { define_method :load do; end }
      dataset_two = Class.new(Dataset::Base) { define_method :load do; end }
      
      @session.add_dataset TestCaseRoot, dataset_one
      @session.add_dataset TestCaseChild, dataset_two
      
      @session.load_datasets_for TestCaseRoot
      @session.load_datasets_for TestCaseChild
      @session.load_datasets_for test_subclass_peer
    end
  end
end