require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Dataset::Session do
  before do
    @session = Dataset::Session.new(Dataset::Database::Sqlite3.new(SQLITE_DATABASE, "#{SPEC_ROOT}/tmp"))
  end
  
  describe 'dataset associations' do
    before do
      @test_case = Class.new(Test::Unit::TestCase)
      @dataset_one = Class.new(Dataset::Base)
      @dataset_two = Class.new(Dataset::Base)
    end
    
    it 'should allow the addition of datasets for a test' do
      @session.add_dataset @test_case, @dataset_one
      @session.datasets(@test_case).should == [@dataset_one]
      
      @session.add_dataset @test_case, @dataset_two
      @session.datasets(@test_case).should == [@dataset_one, @dataset_two]
      
      @session.add_dataset @test_case, @dataset_one
      @session.datasets(@test_case).should == [@dataset_one, @dataset_two]
    end
    
    it 'should combine datasets from test superclasses into subclasses' do
      test_subclass_one = Class.new(@test_case)
      test_sublcass_one_one = Class.new(test_subclass_one)
      
      @session.add_dataset @test_case, @dataset_one
      @session.add_dataset test_subclass_one, @dataset_two
      @session.add_dataset test_subclass_one, @dataset_one
      @session.datasets(test_sublcass_one_one).should == [@dataset_one, @dataset_two]
    end
  end
  
  describe Dataset::Session, 'dataset loading' do
    before do
      @test_case = Class.new(Test::Unit::TestCase)
      @test_subclass = Class.new(@test_case)
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
      
      @session.add_dataset @test_case, dataset_two
      @session.add_dataset @test_case, dataset_one
      @session.load_datasets @test_case
      load_order.should == [dataset_two, dataset_one]
    end
    
    it 'should happen only once per test in a hierarchy' do
      load_count = 0
      
      dataset = Class.new(Dataset::Base) {
        define_method :load do
          load_count += 1
        end
      }
      
      @session.add_dataset @test_case, dataset
      @session.load_datasets @test_case
      load_count.should == 1
      
      @session.load_datasets @test_case
      load_count.should == 1
      
      @session.load_datasets @test_subclass
      load_count.should == 1
    end
    
    it 'should create a snapshot of the existing data before loading a subclass dataset, restoring it next time' do
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
      
      @session.add_dataset @test_case, dataset_one
      @session.add_dataset @test_subclass, dataset_two
      
      @session.load_datasets @test_case
      dataset_one_load_count.should == 1
      dataset_two_load_count.should == 0
      Thing.count.should == 1
      Place.count.should == 0
      
      @session.load_datasets @test_subclass
      dataset_one_load_count.should == 1
      dataset_two_load_count.should == 1
      Thing.count.should == 1
      Place.count.should == 1
      
      @session.load_datasets @test_case
      dataset_one_load_count.should == 1
      dataset_two_load_count.should == 1
      Thing.count.should == 1
      Place.count.should == 0
    end
  end
end