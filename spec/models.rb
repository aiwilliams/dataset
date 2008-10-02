class Person < ActiveRecord::Base
  attr_protected :last_name
end
class Place < ActiveRecord::Base; end
class Thing < ActiveRecord::Base; end
class Note < ActiveRecord::Base; end