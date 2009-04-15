require 'twitter'

# Twitter utilities
class TwitterUtils

  def TwitterUtils.get_client
    auth = Twitter::HTTPAuth.new('wsif', 'oldman')
    Twitter::Base.new(auth)
  end

end