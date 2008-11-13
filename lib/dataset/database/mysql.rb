module Dataset
  module Database
    class Mysql < Base
      def initialize(database_spec, storage_path)
        @database = database_spec[:database]
        @username = database_spec[:username]
        @password = database_spec[:password]
        @storage_path = storage_path
      end
      
      def capture(datasets)
        return if datasets.nil? || datasets.empty?
        `mysqldump --username=#{@username} --password=#{@password} --compact --extended-insert --no-create-db --add-drop-table --quick --quote-names #{@database} > #{storage_path(datasets)}`
      end
      
      def restore(datasets)
        store = storage_path(datasets)
        if File.file?(store)
          `mysql --username=#{@username} --password=#{@password} --database=#{@database} < #{store}`
          true
        end
      end
    end
  end
end