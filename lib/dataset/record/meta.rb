module Dataset
  module Record # :nodoc:
    
    # A mechanism to cache information about an ActiveRecord class to speed
    # things up a bit for insertions, finds, and method generation.
    class Meta # :nodoc:
      attr_reader :class_name, :columns, :record_class, :table_name
      
      def initialize(record_class)
        @record_class     = record_class
        @class_name       = record_class.name
        @table_name       = record_class.table_name
        @columns          = record_class.columns
      end
      
      def timestamp_columns
        @timestamp_columns ||= begin
          timestamps = %w(created_at created_on updated_at updated_on)
          columns.select do |column|
            timestamps.include?(column.name)
          end
        end
      end
      
      def id_reader
        @id_reader ||= begin
          reader = ActiveRecord::Base.pluralize_table_names ? table_name.singularize : table_name
          "#{reader}_id".to_sym
        end
      end
      
      def record_reader
        @record_reader ||= table_name.to_sym
      end
      
      def to_s
        "#<RecordMeta: #{table_name}>"
      end
    end
    
  end
end