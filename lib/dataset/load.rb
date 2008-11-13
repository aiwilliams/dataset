module Dataset
  class Load # :nodoc:
    attr_reader :datasets, :dataset_binding
    
    def initialize(datasets, parent_binding)
      @datasets = datasets
      @dataset_binding = SessionBinding.new(parent_binding)
    end
    
    def execute(loaded_datasets, dataset_resolver)
      (datasets - loaded_datasets).each do |dataset|
        instance = dataset.new
        instance.extend dataset_binding.record_methods
        used_datasets(dataset, dataset_resolver).uniq.each {|ds| instance.extend ds.helper_methods}
        instance.load
      end
    end
    
    def used_datasets(dataset, dataset_resolver, collector = [])
      dataset.used_datasets.each do |used|
        ds = dataset_resolver.resolve(used)
        collector << ds
        used_datasets(ds, dataset_resolver, collector)
      end if dataset.used_datasets
      collector
    end
  end
end