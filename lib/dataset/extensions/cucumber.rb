module Dataset
  module Extensions # :nodoc:

    module CucumberWorld # :nodoc:
      def dataset(*datasets, &block)
        add_dataset(*datasets, &block)

        load = nil
        $__cucumber_toplevel.Before do
          load = dataset_session.load_datasets_for(self.class)
          extend_from_dataset_load(load)
        end
        # Makes sure the datasets are reloaded after each scenario
        Cucumber::Rails.use_transactional_fixtures
      end
    end

  end
end
Cucumber::Rails::World.extend Dataset::Extensions::CucumberWorld