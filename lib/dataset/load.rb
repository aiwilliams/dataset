module Dataset
  class Load
    attr_reader :datasets, :dataset_binding
    
    def initialize(datasets, parent_binding)
      @datasets = datasets
      @dataset_binding = SessionBinding.new(parent_binding)
    end
    
    def execute(loaded_datasets)
      (datasets - loaded_datasets).each do |dataset|
        instance = dataset.new
        instance.extend dataset_binding.record_methods
        instance.load
      end
    end
  end
end