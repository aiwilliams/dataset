module Dataset
  class Base
    class << self
      # Allows a subclass to define helper methods that should be made
      # available to instances of this dataset, to datasets that use this
      # dataset, and to tests that use this dataset.
      #
      # This feature is great for providing any kind of method that would help
      # test the code around the data your dataset creates. Be careful,
      # though, to keep from adding business logic to these methods! That
      # belongs in your production code.
      #
      def helpers(&method_definitions)
        @helper_methods ||= begin
          mod = Module.new
          include mod
          mod
        end
        @helper_methods.module_eval &method_definitions
      end
      
      def helper_methods # :nodoc:
        @helper_methods
      end
      
      # Allows a subsclass to declare which datasets it uses.
      #
      # Dataset is designed to promote 'design by composition', rather than
      # 'design by inheritance'. You should not use class hiearchies to share
      # data and code in your datasets. Instead, you can write something like
      # this:
      #
      #   class PeopleDataset < Dataset::Base; end
      #   class DepartmentsDataset < Dataset::Base; end
      #   class OrganizationsDataset < Dataset::Base
      #     uses :people, :departments
      #   end
      #
      # When the OrganizationsDataset is loaded, it will have all the data
      # from the datasets is uses, as well as all of the helper methods
      # defined by those datasets.
      #
      # When a dataset uses other datasets, and those datasets themselves use
      # datasets, things will be loaded in the order of dependency you would
      # expect:
      #
      #   C uses B
      #   A uses C
      #   B, C, A is the load order
      # 
      def uses(*datasets)
        @used_datasets = datasets
      end
      
      def used_datasets # :nodoc:
        @used_datasets
      end
    end
    
    def load; end
  end
  
  class Block < Base
    def load
      doload
      instance_variables.each do |name|
        dataset_session_binding.block_variables[name] = instance_variable_get(name)
      end
    end
  end
end