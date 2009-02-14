class Person < ActiveRecord::Base
  attr_protected :last_name
end
class Place < ActiveRecord::Base
  set_table_name 'places_table'
end
class Thing < ActiveRecord::Base; end
class Note < ActiveRecord::Base; end
class State < Place; end
class NorthCarolina < State; end