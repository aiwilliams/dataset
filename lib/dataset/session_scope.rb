module Dataset
  class SessionScope
    attr_reader :database
    
    def initialize(database)
      @database = database
      @symbolic_names_to_ids = Hash.new {|h,k| h[k] = {}}
    end
    
    def create_model(record_type, *args)
      insert(Dataset::Record::Model, record_type, *args)
    end
    
    def create_record(record_type, *args)
      insert(Dataset::Record::Fixture, record_type, *args)
    end
    
    def find_model(record_type, symbolic_name)
      record_class = resolve_record_class record_type
      record_class.find @symbolic_names_to_ids[record_class][symbolic_name]
    end
    
    protected
      def insert(dataset_record_class, record_type, *args)
        symbolic_name, attributes = extract_creation_arguments args
        record_class = resolve_record_class record_type
        record_meta  = database.record_meta record_class
        record       = dataset_record_class.new(record_meta, attributes, symbolic_name)
        return_value = nil
        ActiveRecord::Base.silence do
          return_value = record.create
          @symbolic_names_to_ids[record.record_class][symbolic_name] = record.id
          # data_session.update_table_readers(record)
          # self.extend data_session.table_readers
        end
        return_value
      end
      
      def extract_creation_arguments(arguments)
        if arguments.size == 2 && arguments.last.kind_of?(Hash)
          arguments
        elsif arguments.size == 1 && arguments.last.kind_of?(Hash)
          [nil, arguments[0]]
        else
          [nil, Hash.new]
        end
      end
      
      def resolve_record_class(record_type)
        case record_type
        when Symbol
          resolve_record_class record_type.to_s.singularize.camelize
        when Class
          record_type
        when String
          record_type.constantize
        end
      end
      
  end
end