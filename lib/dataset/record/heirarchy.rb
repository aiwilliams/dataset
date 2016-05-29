module Dataset
  module Record # :nodoc:
    
    class Heirarchy # :nodoc:
      attr_reader :base_class, :class_name, :columns, :table_name
      
      delegate :inheritance_column, :to => :base_class
      
      def initialize(base_class)
        @base_class = base_class
        @class_name = base_class.name
        @table_name = base_class.table_name
        @columns    = base_class.columns
      end
      
      def id_cache_key
        @id_cache_key ||= table_name
      end
      
      def id_finder_names
        @id_finder_names ||= [id_finder_name(base_class)]
      end
      
      def model_finder_names
        @model_finder_names ||= [model_finder_name(base_class)]
      end
      
      def to_s
        "#<Heirarchy: #{table_name}>"
      end
      
      def update(record_class)
        record_class.ancestors.each do |c|
          next unless c.is_a? Class
          finder_name = model_finder_name(c)
          unless model_finder_names.include?(finder_name)
            model_finder_names << finder_name
            id_finder_names << id_finder_name(c)
          end
        end
      end
      
      def finder_name(klass)
        klass.name.underscore.gsub('/', '_').sub(/^(\w)_/, '\1').gsub(/_(\w)_/, '_\1')
      end
      
      def id_finder_name(klass)
        "#{finder_name(klass)}_id".to_sym
      end
      
      def model_finder_name(klass)
        finder_name(klass).pluralize.to_sym
      end
      
      def timestamp_columns
         @timestamp_columns ||= begin
           timestamps = %w(created_at created_on updated_at updated_on)
           columns.select do |column|
             timestamps.include?(column.name)
           end
         end
      end
    end
    
  end
end
