class Test::Unit::TestCase
  def self.dataset(dataset)
    dataset_session.add_dataset(self, dataset)
  end
  
  def self.dataset_session
    @dataset_session ||= Dataset::Session.new(Dataset::Database::Base.new)
  end
  
  def dataset_session
    self.class.dataset_session
  end
end

class Test::Unit::TestSuite
  def run_with_dataset(result, &progress_block)
    first_test_in_suite = tests.first
    first_test_in_suite.dataset_session.load_datasets_for(first_test_in_suite.class)
    run_without_dataset(result, &progress_block)
  end
  alias run_without_dataset run
  alias run run_with_dataset
end