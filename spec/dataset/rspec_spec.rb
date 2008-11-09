require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

class Spec::Example::ExampleGroup
  include Dataset
end

describe Spec::Example::ExampleGroup do
  include SandboxedOptions
  
  it 'should have a dataset method' do
    group = Class.new(Spec::Example::ExampleGroup)
    group.should respond_to(:dataset)
  end
  
  it 'should load the dataset when the group is run' do
    load_count = 0
    dataset = Class.new(Dataset::Base) do
      define_method(:load) do
        load_count += 1
      end
    end
    
    group = Class.new(Spec::Example::ExampleGroup) do
      self.dataset(dataset)
      it('one') {}
      it('two') {}
    end
    
    group.run
    load_count.should be(1)
  end
  
  it 'should load datasets in nested groups' do
    dataset_one = Class.new(Dataset::Base) do
      define_method(:load) do
        Thing.create!
      end
    end
    dataset_two = Class.new(Dataset::Base) do
      define_method(:load) do
        Place.create!
      end
    end
    
    group = Class.new(Spec::Example::ExampleGroup) do
      dataset(dataset_one)
      it('one') {}
    end
    group_child = Class.new(group) do
      dataset(dataset_two)
      it('two') {}
    end
    
    group.run
    Thing.count.should be(1)
    Place.count.should be(0)
    
    group_child.run
    Thing.count.should be(1)
    Place.count.should be(1)
  end
  
  it 'should expose data reading methods from dataset binding to the test methods through the test instances' do
    created_model = nil
    dataset = Class.new(Dataset::Base) do
      define_method(:load) do
        created_model = create_model(Thing, :mything)
      end
    end
    
    found_in_before_all, found_in_it = nil
    group = Class.new(Spec::Example::ExampleGroup) do
      self.dataset(dataset)
      before(:all) do
        found_in_before_all = things(:mything)
      end
      it 'one' do
        found_in_it = things(:mything)
      end
    end
    
    group.run
    group.should_not respond_to(:things)
    
    found_in_it.should_not be_nil
    found_in_it.should == created_model
    
    found_in_before_all.should_not be_nil
    found_in_before_all.should == created_model
  end
end