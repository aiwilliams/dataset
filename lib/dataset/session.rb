module Dataset
  class Session
    def initialize(database)
      @database = database
      @datasets = Hash.new
      @loaded_datasets = []
    end
    
    def add_dataset(test_class, dataset)
      datasets_for(test_class) << dataset
    end
    
    def datasets_for(test_class)
      if test_class.superclass
        @datasets[test_class] ||= Collection.new(datasets_for(test_class.superclass) || [])
      end
    end
    
    def load_datasets_for(test_class)
      current_load = datasets_for(test_class)
      return if current_load == @last_load
      
      if @last_load
        if @last_load.subset?(current_load)
          @database.capture(@last_load)
          load_datasets(current_load)
        elsif !@database.restore(current_load)
          load_datasets(current_load)
        end
      else
        load_datasets(current_load)
      end
    end
    
    protected
      def load_datasets(datasets)
        datasets.each do |dataset|
          unless @loaded_datasets.include?(dataset)
            dataset.new.load
            @loaded_datasets << dataset
          end
        end
        @last_load = datasets
      end
  end
end