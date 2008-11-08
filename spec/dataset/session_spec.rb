require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

TestCaseRoot = Class.new(Test::Unit::TestCase)
TestCaseChild = Class.new(TestCaseRoot)
TestCaseSibling = Class.new(TestCaseRoot)
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
    
    it 'should include those that a dataset declares it uses' do
      dataset = Class.new(Dataset::Base) do
        uses DatasetTwo, DatasetOne
      end
      @session.add_dataset TestCaseRoot, dataset
      @session.add_dataset TestCaseChild, DatasetTwo
      @session.datasets_for(TestCaseChild).should == [DatasetTwo, DatasetOne, dataset]
      @session.datasets_for(TestCaseGrandchild).should == [DatasetTwo, DatasetOne, dataset]
    end
  end
  
  describe 'dataset loading' do
    it 'should clear the database on first load' do
      @database.should_receive(:clear).once()
      dataset_one = Class.new(Dataset::Base)
      dataset_two = Class.new(Dataset::Base)
      @session.add_dataset TestCaseRoot, dataset_one
      @session.add_dataset TestCaseChild, dataset_one
      @session.load_datasets_for(TestCaseRoot)
      @session.load_datasets_for(TestCaseChild)
    end
    
    it 'should clear the database on loads where there is no subset' do
      @database.should_receive(:clear).twice()
      dataset_one = Class.new(Dataset::Base)
      dataset_two = Class.new(Dataset::Base)
      @session.add_dataset TestCaseChild, dataset_one
      @session.add_dataset TestCaseSibling, dataset_two
      @session.load_datasets_for(TestCaseChild)
      @session.load_datasets_for(TestCaseSibling)
    end
    
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
      
      @session.load_datasets_for TestCaseSibling
      dataset_one_load_count.should == 1
      dataset_two_load_count.should == 1
      Thing.count.should == 1
      Place.count.should == 0
    end
    
    it 'should install the record methods into the datasets' do
      instance_of_dataset_one = nil
      dataset_one = Class.new(Dataset::Base) do
        define_method :load do
          instance_of_dataset_one = self
        end
      end
      
      @session.add_dataset TestCaseRoot, dataset_one
      @session.load_datasets_for TestCaseRoot
      instance_of_dataset_one.should_not be_nil
      instance_of_dataset_one.should respond_to(:create_record)
      instance_of_dataset_one.should respond_to(:create_model)
      instance_of_dataset_one.should respond_to(:find_model)
      instance_of_dataset_one.should respond_to(:find_id)
    end
  end
  
  describe 'bindings' do
    it 'should be created for each dataset load, wrapping the outer binding' do
      scope_one   = Dataset::SessionBinding.new(@database)
      scope_two   = Dataset::SessionBinding.new(scope_one)
      scope_three = Dataset::SessionBinding.new(scope_one)
      
      Dataset::SessionBinding.should_receive(:new).with(@database).and_return(scope_one)
      Dataset::SessionBinding.should_receive(:new).with(scope_one).twice().and_return(scope_two)
      
      dataset_one = Class.new(Dataset::Base) { define_method :load do; end }
      dataset_two = Class.new(Dataset::Base) { define_method :load do; end }
      
      @session.add_dataset TestCaseRoot, dataset_one
      @session.add_dataset TestCaseChild, dataset_two
      
      @session.load_datasets_for TestCaseRoot
      @session.load_datasets_for TestCaseChild
      @session.load_datasets_for TestCaseSibling
    end
  end
end