# Campaign represents a collection of stored queries.
class Campaign < ActiveRecord::Base
  validates_presence_of :name

  
end
