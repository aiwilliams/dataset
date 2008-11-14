Dataset
=========

*Data for Your Tests.*

Quick Start
-----------

Dataset provides a simple API for creating sets of data in your database. Here it is:

* create_record(:my_type, :somename, :attr => 'value')
  A classic fixture insert. Returns the id. :somename is optional.
  
* create_model(:my_type, :somename, :attr => 'value')
  Instantiates your record class, saves it. Returns the record. :somename is optional.
  
* name_model(model, :somename)
  Gives your already created model a name.
  
* find_id(:my_type, :somename)
  Answer the id of MyType having :somename. The database is not used.
  
* find_model(:my_type, :somename)
  Answer an instance of MyType having :somename. The database is used.
  
  
Dataset loads data intelligently if you use 'nested contexts' in your tests (RSpec, anything that uses Test::Unit::TestCase subclassing for creating nested contexts):

    describe Something do
      dataset :a              => Dataset :a is loaded (at the right time)
                              
      it 'should whatever'    
      end                     
                              
      describe More do        
        dataset :b            => Dataset :b is loaded. :a data is still there
                              
        it 'should'           
        end                   
      end                     
                              
      describe Another do     => Database is restored to :a, without re-running :a logic
        it 'should'
        end
      end
    end
  
The goal is to see a marked improvement in overall test run speed, basing this on the assumption that it is faster to have the OS copy a file or mySQL dump and load. Of course, we may find this to be a false assumption, but there were plenty of bugs in the former 'Scenarios' - addressing that afforded the opportunity to test the assumption.


Dataset does not prevent you from using other libraries like Machinist or factory_girl. If you were to used either of those, you could have a dataset like this:
  
    require 'faker'
    
    class OrganizationsDataset < Dataset::Base
      Sham.name  { Faker::Name.name }
      
      Organization.blueprint do
        name { Sham.name }
      end
      
      def load
        name_model Organization.make, :org_one
      end
    end
  
The benefit is that you can reuse interesting sets of data, without sacrificing the utility of those other libraries.

    describe Organization, 'stuff' do
      dataset :organizations
    end
    
    describe Organization, 'other stuff' do
      dataset :organizations
    end
  

There is more sugar to it (like helpers, dataset blocks), but that's a good quick start.

Installation
------------

Install the plugin:

    ./script/plugin install git://github.com/aiwilliams/dataset.git

In your test_helper.rb/spec_helper.rb:

    require 'dataset'
    class Test::Unit::TestCase
      include Dataset
    end

If you don't use rspec_on_rails, or you have specs that aren't of the RailsExampleGroup type, you should do this in spec_helper.rb:

    require 'dataset'
    class Spec::Example::ExampleGroup
      include Dataset
    end

If you were a user of my Scenarios plugin, and want to do as little as possible to get going (assumes you are using rspec_on_rails):

    require 'dataset'
    Scenario = Scenarios = Dataset
    class Test::Unit::TestCase
      include Dataset
      class << self
        alias_method :scenario, :dataset
      end
    end
    class ScenariosResolver < Dataset::DirectoryResolver
      def suffix
        @suffix ||= 'Scenario'
      end
    end
    Dataset::Resolver.default = ScenariosResolver.new(dir + '/scenarios')


Credits
-------

Written by [Adam Williams](http://github.com/aiwilliams).
    
Contributors:

- [Steve Iannopollo](http://github.com/siannopollo)
- [John Long](http://github.com/jlong)

---

Dataset is released under the MIT-License and is Copyright (c)2008 Adam Williams.