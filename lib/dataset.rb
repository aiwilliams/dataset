require 'dataset/base'
require 'dataset/database/base'
require 'dataset/database/mysql'
require 'dataset/database/sqlite3'
require 'dataset/collection'
require 'dataset/session'
require 'dataset/session_binding'
require 'dataset/record/meta'
require 'dataset/record/fixture'
require 'dataset/record/model'

require 'dataset/extensions/test_unit' if defined?(Test::Unit)

module Dataset
end