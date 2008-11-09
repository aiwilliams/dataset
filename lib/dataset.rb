require 'dataset/base'
require 'dataset/database/base'
require 'dataset/database/mysql'
require 'dataset/database/sqlite3'
require 'dataset/collection'
require 'dataset/load'
require 'dataset/session'
require 'dataset/session_binding'
require 'dataset/record/meta'
require 'dataset/record/fixture'
require 'dataset/record/model'

module Dataset
  def self.included(test_context)
    if test_context.name =~ /TestCase\Z/
      require 'dataset/extensions/test_unit'
    elsif test_context.name =~ /ExampleGroup\Z/
      require 'dataset/extensions/rspec'
    else
      raise "I don't understand your test framework"
    end
  end
end