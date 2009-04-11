# Metadata about a tweet. Does not contain the tweet body.
# Comes from the gnip api.
class TweetInfo < ActiveRecord::Base

  # Calculate the tweets per day for the given uid
  def TweetInfo.tweets_per_day(uid, from_days = 7)
    to = Date.today - 1
    from = Date.today - from_days

    # TODO caching
    count(:conditions => ["uid=? and posted_at >= ? and posted_at <= ?", uid, from, to])
  end

  def TweetInfo.replies_per_day(uid, from_days = 7)
    to = Date.today - 1
    from = Date.today - from_days

    # TODO caching
    count(:conditions => ["uid=? and in_reply_to is not null and posted_at >= ? and posted_at <= ?", uid, from, to])
  end
end
