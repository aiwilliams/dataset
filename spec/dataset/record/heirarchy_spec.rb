require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class MThingy
  class NThingy
  end
end

describe Dataset::Record::Heirarchy, 'finder name' do
  it 'should collapse single character followed by underscore to just the single character' do
    @heirarchy = Dataset::Record::Heirarchy.new(Place)
    @heirarchy.finder_name(MThingy).should == 'mthingy'
    @heirarchy.finder_name(MThingy::NThingy).should == 'mthingy_nthingy'
  end
end