require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

ResolveThis = Class.new(Dataset::Base)
ResolveDataset = Class.new(Dataset::Base)

describe Dataset::Resolver do
  before do
    @resolver = Dataset::Resolver.new
  end
  
  it 'should find simply classified' do
    @resolver.resolve(:resolve_this).should == ResolveThis
  end
  
  it 'should find ending with Dataset' do
    @resolver.resolve(:resolve).should == ResolveDataset
  end
  
  it 'should indicate that it could not find a dataset' do
    lambda do
      @resolver.resolve(:undefined)
    end.should raise_error(
      Dataset::DatasetNotFound,
      "Could not find a dataset 'Undefined' or 'UndefinedDataset'."
    )
  end
end

describe Dataset::DirectoryResolver do
  before do
    @resolver = Dataset::DirectoryResolver.new(SPEC_ROOT + '/fixtures/datasets')
  end
  
  it 'should find file with exact name match' do
    defined?(ExactName).should be_nil
    dataset = @resolver.resolve(:exact_name)
    defined?(ExactName).should == 'constant'
    dataset.should == ExactName
  end
  
  it 'should find file with name ending in _dataset' do
    defined?(EndingWithDataset).should be_nil
    dataset = @resolver.resolve(:ending_with)
    defined?(EndingWithDataset).should == 'constant'
    dataset.should == EndingWithDataset
  end
  
  it 'should indicate that it could not find a dataset file' do
    lambda do
      @resolver.resolve(:undefined)
    end.should raise_error(
      Dataset::DatasetNotFound,
      "Could not find a dataset file in '#{SPEC_ROOT + '/fixtures/datasets'}' having the name 'undefined.rb' or 'undefined_dataset.rb'."
    )
  end
  
  it 'should indicate when it finds a file, but the constant is not defined after loading the file' do
    lambda do
      @resolver.resolve(:constant_not_defined)
    end.should raise_error(
      Dataset::DatasetNotFound,
      "Found the dataset file '#{SPEC_ROOT + '/fixtures/datasets/constant_not_defined.rb'}', but it did not define a dataset 'ConstantNotDefined' or 'ConstantNotDefinedDataset'."
    )
  end
end