require 'active_record/fixtures'

module Dataset
  module Record # :nodoc:
    
    class Fixture # :nodoc:
      attr_reader :meta, :symbolic_name
      
      def initialize(meta, attributes, symbolic_name = nil)
        @meta          = meta
        @attributes    = attributes.stringify_keys
        @symbolic_name = symbolic_name || object_id
        install_default_attributes!
      end
      
      def create
        record_class.connection.insert_fixture to_fixture, meta.table_name
        id
      end
      
      def id
        @attributes['id']
      end
      
      def record_class
        meta.record_class
      end
      
      def to_hash
        @attributes
      end
      
      def to_fixture
        ::Fixture.new(to_hash, meta.class_name)
      end
      
      def install_default_attributes!
        @attributes['id'] ||= symbolic_name.to_s.hash.abs
        install_timestamps!
      end
      
      def install_timestamps!
        meta.timestamp_columns.each do |column|
          @attributes[column.name] = now(column) unless @attributes.key?(column.name)
        end
      end
      
      def now(column)
        (ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now).to_s(:db)
      end
    end
    
  end
end