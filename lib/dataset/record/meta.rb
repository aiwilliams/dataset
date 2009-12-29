module Dataset
  module Record # :nodoc:
    
    # A mechanism to cache information about an ActiveRecord class to speed
    # things up a bit for insertions, finds, and method generation.
    class Meta # :nodoc:
      attr_reader :heirarchy, :class_name, :record_class
      
      # Provides information necessary to insert STI classes correctly for
      # later reading.
      delegate :name, :sti_name, :to => :record_class
      delegate :inheritance_column, :table_name, :timestamp_columns, :to => :heirarchy
      
      def initialize(heirarchy, record_class)
        @heirarchy    = heirarchy
        @record_class = record_class
        @class_name   = record_class.name
      end
      
      def inheriting_record?
        !record_class.descends_from_active_record?
      end
      
      def to_s
        "#<RecordMeta: #{table_name}>"
      end
    end
    
  end
end
