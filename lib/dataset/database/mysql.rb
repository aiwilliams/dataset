module Dataset
  module Database
    class Mysql < Base
      def capture(datasets)
        # mysqldump --compact --extended-insert --no-create-db --no-create-info --quick database
      end
      
      def restore(datasets)
      end
    end
  end
end