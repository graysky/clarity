require 'test_helper'

class CampaignTest < ActiveSupport::TestCase
  # Must have a name
  should_validate_presence_of :name
  
  #test "the truth" do
  #  assert true
  #end
end
