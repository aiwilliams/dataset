module Dataset
  # An error raised when a dataset class cannot be found.
  #
  class DatasetNotFound < StandardError
  end
  
  # A dataset may be referenced as a class or as a name. A Dataset::Resolver
  # will take an identifier, whether a class or a name, and return the class.
  #
  class Resolver
    cattr_accessor :default
    
    # Attempt to convert a name to a constant. With the identifier :people, it
    # will search for 'PeopleDataset', then 'People'.
    #
    def resolve(identifier)
      return identifier if identifier.is_a?(Class)
      begin
        resolve_class(identifier)
      rescue
        resolve_identifier(identifier)
      end
    end
    
    protected
      def resolve_class(identifier) # :nodoc:
        names = [identifier.to_s.camelize, identifier.to_s.camelize + suffix]
        constant = resolve_these(names.reverse)
        unless constant
          raise Dataset::DatasetNotFound, "Could not find a dataset #{names.collect{|n| "'#{n}'"}.join(' or ')}."
        else
          raise Dataset::DatasetNotFound, "Found a class '#{constant.name}', but it does not subclass 'Dataset::Base'." unless constant.superclass == ::Dataset::Base
        end
        constant
      end
      alias resolve_identifier resolve_class
      
      def resolve_these(names) # :nodoc:
        names.each do |name|
          constant = name.constantize rescue nil
          return constant if constant
        end
        nil
      end
      
      def suffix # :nodoc:
        @suffix ||= 'Dataset'
      end
  end
  
  # Resolves a dataset by looking for a file in the provided directory path
  # that has a name matching the identifier. Of course, should the identifier
  # be a class already, it is simply returned.
  #
  class DirectoryResolver < Resolver
    def initialize(path)
      @path = path
    end
    
    protected
      def resolve_identifier(identifier) # :nodoc:
        file = File.join(@path, identifier.to_s)
        unless File.exists?(file + '.rb')
          file = file + '_' + file_suffix
          unless File.exists?(file + '.rb')
            raise DatasetNotFound, "Could not find a dataset file in '#{@path}' having the name '#{identifier}.rb' or '#{identifier}_#{file_suffix}.rb'."
          end
        end
        require file
        begin
          super
        rescue Dataset::DatasetNotFound => dnf
          if dnf.message =~ /\ACould not find/
            raise Dataset::DatasetNotFound, "Found the dataset file '#{file + '.rb'}', but it did not define #{dnf.message.sub('Could not find ', '')}"
          else
            raise Dataset::DatasetNotFound, "Found the dataset file '#{file + '.rb'}' and a class #{dnf.message.sub('Found a class ', '')}"
          end
        end
      end
      
      def file_suffix # :nodoc:
        @file_suffix ||= suffix.downcase
      end
  end
  
  # The default resolver, used by the Dataset::Sessions that aren't given a
  # different instance. You can set this to something else in your
  # test/spec_helper.
  #
  Resolver.default = Resolver.new
  
end