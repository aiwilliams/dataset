module Dataset
  class Base
    class << self
      def uses(*datasets)
        @used_datasets = datasets
      end
      
      # Class method that returns the datasets used by your dataset.
      def used_datasets # :nodoc:
        @used_datasets
      end
    end
    
    def load; end
  end
end