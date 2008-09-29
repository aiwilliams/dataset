SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
require "#{SPEC_ROOT}/../plugit/descriptor"

$LOAD_PATH << "#{SPEC_ROOT}/../lib"
RAILS_ROOT = "#{SPEC_ROOT}/.."
RAILS_LOG_FILE = "#{RAILS_ROOT}/log/test.log"
SQLITE_DATABASE = "#{SPEC_ROOT}/sqlite3.db"

require 'fileutils'
FileUtils.mkdir_p(File.dirname(RAILS_LOG_FILE))
FileUtils.touch(RAILS_LOG_FILE)
FileUtils.mkdir_p("#{SPEC_ROOT}/tmp")
FileUtils.rm_rf("#{SPEC_ROOT}/tmp/*")

require 'logger'
RAILS_DEFAULT_LOGGER = Logger.new(RAILS_LOG_FILE)
RAILS_DEFAULT_LOGGER.level = Logger::DEBUG

ActiveRecord::Base.silence do
  ActiveRecord::Base.configurations = {'sqlite3' => {
    'adapter' => 'sqlite3',
    'database' => SQLITE_DATABASE
  }}
  ActiveRecord::Base.establish_connection 'sqlite3'
  load "#{SPEC_ROOT}/schema.rb"
end

require "models"
require "dataset"