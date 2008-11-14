module Dataset
  class RecordNotFound < StandardError
    def initialize(record_type, symbolic_name)
      super "There is no '#{record_type.name}' found for the symbolic name ':#{symbolic_name}'."
    end
  end
  
  class SessionBinding
    attr_reader :database, :parent_binding
    attr_reader :instance_loaders, :record_methods
    
    def initialize(database_or_parent_binding)
      @symbolic_names_to_ids = Hash.new {|h,k| h[k] = {}}
      @record_methods = new_record_methods_module
      @instance_loaders = new_instance_loaders_module
      
      case database_or_parent_binding
      when Dataset::SessionBinding
        @parent_binding = database_or_parent_binding
        @database = parent_binding.database
        @instance_loaders.module_eval { include database_or_parent_binding.instance_loaders }
      else 
        @database = database_or_parent_binding
      end
    end
    
    def create_model(record_type, *args)
      insert(Dataset::Record::Model, record_type, *args)
    end
    
    def create_record(record_type, *args)
      insert(Dataset::Record::Fixture, record_type, *args)
    end
    
    def find_id(record_type, symbolic_name)
      record_class = resolve_record_class record_type
      if local_id = @symbolic_names_to_ids[record_class][symbolic_name]
        local_id
      elsif !parent_binding.nil?
        parent_binding.find_id record_type, symbolic_name
      else
        raise RecordNotFound.new(record_type, symbolic_name)
      end
    end
    
    def find_model(record_type, symbolic_name)
      record_class = resolve_record_class record_type
      if local_id = @symbolic_names_to_ids[record_class][symbolic_name]
        record_class.find local_id
      elsif !parent_binding.nil?
        parent_binding.find_model record_type, symbolic_name
      else
        raise RecordNotFound.new(record_type, symbolic_name)
      end
    end
    
    protected
      def insert(dataset_record_class, record_type, *args)
        symbolic_name, attributes = extract_creation_arguments args
        record_class = resolve_record_class record_type
        record_meta  = database.record_meta record_class
        record       = dataset_record_class.new(record_meta, attributes, symbolic_name)
        @instance_loaders.create_loader(record.record_class) unless @symbolic_names_to_ids.has_key?(record.record_class)
        return_value = nil
        ActiveRecord::Base.silence do
          return_value = record.create
          @symbolic_names_to_ids[record.record_class][symbolic_name] = record.id
        end
        return_value
      end
      
      def extract_creation_arguments(arguments)
        if arguments.size == 2 && arguments.last.kind_of?(Hash)
          arguments
        elsif arguments.size == 1 && arguments.last.kind_of?(Hash)
          [nil, arguments.last]
        elsif arguments.size == 1 && arguments.last.kind_of?(Symbol)
          [arguments.last, Hash.new]
        else
          [nil, Hash.new]
        end
      end
      
      # Describe this as a wrapper around a binding, so that folks who want
      # these methods don't have to do something like:
      #
      #   session_binding.create_record *args
      #
      def new_instance_loaders_module
        mod = Module.new
        
        dataset_binding = self
        mod.module_eval do
          define_method :dataset_session_binding do
            dataset_binding
          end
        end
        
        class << mod
          def create_loader(record_class)
            record_loader_base_name = record_class.name.underscore
            define_method record_loader_base_name.pluralize do |symbolic_name|
              dataset_session_binding.find_model(record_class, symbolic_name)
            end
            define_method "#{record_loader_base_name}_id" do |symbolic_name|
              dataset_session_binding.find_id(record_class, symbolic_name)
            end
          end
        end
        
        mod
      end
      
      def new_record_methods_module
        mod = Module.new do
          delegate :create_record, :create_model, :find_id, :find_model,
            :to => :dataset_session_binding
        end
        
        dataset_binding = self
        mod.module_eval do
          define_method :dataset_session_binding do
            dataset_binding
          end
        end
        
        mod
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