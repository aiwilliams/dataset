require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Dataset::SessionBinding do
  before :all do
    @database = Dataset::Database::Sqlite3.new(SQLITE_DATABASE, "#{SPEC_ROOT}/tmp")
  end
  
  before do
    @database.clear
    @binding = Dataset::SessionBinding.new(@database)
  end
  
  it 'should support direct record inserts like classic fixtures' do
    Thing.should_not_receive :new
    lambda do
      return_value = @binding.create_record Thing
      return_value.should be_kind_of(Integer)
    end.should change(Thing, :count).by(1)
  end
  
  it 'should support creating records by instantiating the record class so callbacks work' do
    thing = Thing.new
    Thing.should_receive(:new).and_return(thing)
    lambda do
      return_value = @binding.create_model Thing
      return_value.should be_kind_of(Thing)
    end.should change(Thing, :count).by(1)
  end
  
  it 'should provide itself to the instance loaders' do
    anything = Object.new
    anything.extend @binding.instance_loaders
    anything.dataset_session_binding.should == @binding
  end
  
  describe 'create_record' do
    it 'should accept raw attributes for the insert' do
      @binding.create_record Thing, :name => 'my thing'
      Thing.last.name.should == 'my thing'
    end
    
    it 'should optionally accept a symbolic name for later lookup' do
      id = @binding.create_record Thing, :my_thing, :name => 'my thing'
      @binding.find_model(Thing, :my_thing).id.should == id
      @binding.find_id(Thing, :my_thing).should == id
    end
    
    it 'should auto-assign _at and _on columns with their respective time types' do
      @binding.create_record Note
      Note.last.created_at.should_not be_nil
      Note.last.updated_at.should_not be_nil
      
      @binding.create_record Thing
      Thing.last.created_on.should_not be_nil
      Thing.last.updated_on.should_not be_nil
    end
    
    it 'should provide an instance loader methods for created types' do
      id = @binding.create_record(Note, :mynote)
      anything = Object.new
      anything.extend @binding.instance_loaders
      anything.notes(:mynote).should_not be_nil
      anything.notes(:mynote).id.should == id
      anything.note_id(:mynote).should == id
    end
  end
  
  describe 'create_model' do
    it 'should accept raw attributes for the insert' do
      @binding.create_model Thing, :name => 'my thing'
      Thing.last.name.should == 'my thing'
    end
    
    it 'should optionally accept a symbolic name for later lookup' do
      thing = @binding.create_model Thing, :my_thing, :name => 'my thing'
      @binding.find_model(Thing, :my_thing).should == thing
      @binding.find_id(Thing, :my_thing).should == thing.id
    end
    
    it 'should bypass mass assignment restrictions' do
      person = @binding.create_model Person, :first_name => 'Adam', :last_name => 'Williams'
      person.last_name.should == 'Williams'
    end
    
    it 'should provide an instance loader methods for created types' do
      note = @binding.create_model Note, :mynote
      anything = Object.new
      anything.extend @binding.instance_loaders
      anything.notes(:mynote).should == note
      anything.note_id(:mynote).should == note.id
    end
  end
  
  describe 'nested bindings' do
    before do
      @binding.create_model Thing, :mything, :name => 'my thing'
      @nested_scope = Dataset::SessionBinding.new(@binding)
    end
    
    it 'should walk up the tree to find models' do
      @nested_scope.find_model(Thing, :mything).should == @binding.find_model(Thing, :mything)
    end
  end
end