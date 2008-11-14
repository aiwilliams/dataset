class Spec::Example::ExampleGroup
  superclass_delegating_accessor :dataset_session
  
  class << self
    def dataset(*datasets, &block)
      dataset_session = dataset_session_in_hierarchy
      datasets.each { |dataset| dataset_session.add_dataset(self, dataset) }
      dataset_session.add_dataset(self, Class.new(Dataset::Block) {
        define_method :doload, block
      }) unless block.nil?
      
      load = nil
      
      before(:all) do
        load = dataset_session.load_datasets_for(self.class)
        self.extend load.dataset_binding.record_methods
        self.extend load.dataset_binding.instance_loaders
        self.extend load.helper_methods
      end
      
      before(:each) do
        self.extend load.dataset_binding.record_methods
        self.extend load.dataset_binding.instance_loaders
        self.extend load.helper_methods
      end
    end
    
    def dataset_session_in_hierarchy
      self.dataset_session ||= begin
        database_spec = ActiveRecord::Base.configurations['test'].with_indifferent_access
        database_class = Dataset::Database.const_get(database_spec[:adapter].classify)
        database = database_class.new(database_spec, File.expand_path(RAILS_ROOT + '/spec/tmp'))
        Dataset::Session.new(database)
      end
    end
  end
end