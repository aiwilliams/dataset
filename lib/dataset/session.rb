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
      
      # if @test_ancestry.nil? || !@test_ancestry.include?(test)
      #   @test_ancestry = test_ancestry test
      #   @scope = SessionBinding.new(@database)
      #   load_root @scope, @test_ancestry, test
      # elsif @test_ancestry.include?(test)
      #   if @test_ancestry.peer?(test)
      #     @scope = SessionBinding.new(@scope.parent_binding)
      #     load_peer @scope, @test_ancestry, test
      #   elsif @test_ancestry.descendent?(test)
      #     @scope = SessionBinding.new(@scope)
      #     load_descendent @scope, @test_ancestry, test
      #   else
      #     raise 'I do not understand how an ancestor could be run'
      #   end
      # else
      #   raise 'I do not understand how it could get here'
      # end
    end
    
    def load_root(ancestry, test)
      @database.clear
      load_dataset ancestry.dataset(test), @scope
      ancestry.active_test = test
    end
    
    def load_peer(ancestry, test)
      datasets_of_prior = datasets ancestry.active_test
      @database.capture datasets_of_prior
      load_dataset ancestry.dataset(test), @scope
    end
    
    def load_descendent(ancestry, test)
      datasets_of_prior = datasets ancestry.active_test
      @database.capture datasets_of_prior
      load_dataset ancestry.dataset(test), @scope
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