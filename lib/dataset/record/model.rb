module Dataset
  module Record # :nodoc:
    
    class Model # :nodoc:
      attr_reader :attributes, :model, :meta, :symbolic_name
      
      def initialize(meta, attributes, symbolic_name = nil)
        @meta          = meta
        @attributes    = attributes.stringify_keys
        @symbolic_name = symbolic_name || object_id
      end
      
      def record_class
        meta.record_class
      end
      
      def id
        model.id
      end
      
      def create
        model = to_model
        model.save!
        model
      end
      
      def to_hash
        to_model.attributes
      end
      
      def to_model
        @model ||= begin
          m = meta.record_class.new
          attributes.each {|k,v| m.send "#{k}=", v}
          m
        end
      end
    end
    
  end
end