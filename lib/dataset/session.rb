module Dataset
  class Session
    def initialize(database = Sqlite3Database.new)
      @database = database
      @test_datasets = Hash.new {|h,k| h[k] = []}
      @loaded_datasets = Hash.new
    end
    
    def add_dataset(test, dataset)
      @test_datasets[test] << dataset
      @test_datasets[test].uniq!
    end
    
    def datasets(test)
      test_ancestry(test).reverse.collect {|c| @test_datasets[c]}.flatten.uniq
    end
    
    def load_datasets(test)
      prior_test, @current_test = @current_test, test
      return if @current_datasets == (datasets = self.datasets(test))
      
      in_prior_test_hierarchy = test_ancestry(@current_test).include?(prior_test)
      if @current_datasets
        @database.capture @current_datasets
        @database.clear unless in_prior_test_hierarchy
      end
      
      unless @database.restore(datasets)
        datasets_to_load = datasets
        datasets_to_load = datasets_to_load - self.datasets(prior_test) if in_prior_test_hierarchy
        datasets_to_load.each do |dataset|
          instance = dataset.new
          instance.load
        end
      end
      
      @current_datasets = datasets
    end
    
    protected
      def test_ancestry(test)
        hierarchy, sup = [], test
        begin
          hierarchy << sup
          sup = sup.superclass
        end until sup == Test::Unit::TestCase
        hierarchy
      end
  end
end