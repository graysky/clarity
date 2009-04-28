# A user of Twitter, as opposed to a user of clarity
class TwitterUser < ActiveRecord::Base


  # Update a twitter user and associated stats
  # Accepts a hash of options
  # - specify one of :id, :uid or :screen_name
  # - :force If true, always update even if nothing has changed. Defaults to false.
  def TwitterUser.update_user(opts = {})

    # First look up the user by uid or screen_name
    user = nil
    if opts[:uid]
      user = TwitterUser.find_by_uid(opts[:uid])
    elsif opts[:screen_name]
      user = TwitterUser.find_by_screen_name(opts[:screen_name])
    elsif opts[:id]
      user = TwitterUser.find(opts[:id])
    end

    if user.nil?
      # First time we have seen this user. Create a new one.
      user = TwitterUser.new
      lookup_id = opts[:uid] || opts[:screen_name]
    else
      lookup_id = user.uid
    end

    begin
      user_info = twitter_api.user(lookup_id)
      return if user_info.nil?

      populate_model_with_user_info(user, user_info)

      # todo has location changed? Re-geocode
      if opts[:force] && !user.changed?
        user.updated_at = Time.now
      end

      # Create a stats record and copy stats into user model
      create_user_stats(user, user_info)

      user.update_failures = 0
      user.save!
    rescue Exception => e
      # Try to increase update_failures
      user.increment('update_failures')
      user.save!

      raise e
    end

    return user
  end

  # Populate our model object with user info data from twitter
  def TwitterUser.populate_model_with_user_info(model, user_info)
    model.uid = user_info.id
    model.screen_name = user_info.screen_name
    model.name = user_info.name
    model.location = user_info.location
    model.description = user_info.description
    model.profile_image_url = user_info.profile_image_url
    model.url = user_info.url
  end

  def TwitterUser.create_user_stats(model, user_info)
    stats = TwitterUserStats.new

    stats.twitter_user_id = user_info.id
    model.followers = stats.followers = user_info.followers_count
    model.following = stats.following = user_info.friends_count

    model.tweets_per_day = stats.tweets_per_day = TweetInfo.tweets_per_day(user_info.id)
    model.replies_per_day = stats.replies_per_day = TweetInfo.replies_per_day(user_info.id)
    model.replies_to_per_day = stats.replies_to_per_day = TweetInfo.replies_to_per_day(user_info.screen_name)
    model.retweeted_per_day = stats.retweeted_per_day = RetweetInfo.retweeted_per_day(user_info.screen_name)
    model.retweets_per_day = stats.retweets_per_day = RetweetInfo.retweets_per_day(user_info.screen_name)

    # todo other stats/classification
    stats.save!
  end

  def TwitterUser.find_users_updated_before(updated_before, limit, max_update_failures = 100)
    find(:all,:conditions => ["updated_at <= ? and update_failures < ?",
                              updated_before, max_update_failures], :limit => limit)
  end

  private

  def TwitterUser.twitter_api
    @@twitter_api ||= TwitterUtils.get_client
  end

end
