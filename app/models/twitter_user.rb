# A user of Twitter, as opposed to a user of clarity
class TwitterUser < ActiveRecord::Base

  # Update a twitter user and associated stats
  # Accepts a hash of options
  # - specify one of :id, :uid or :screen_name
  def TwitterUser.update_user(opts = {})

    # First look up the user by uid or screen_name
    user = nil
    if opts[:uid]
      user = TwitterUser.find_by_uid(opts[:uid])
    elsif opts[:screen_name]
      user = TwitterUser.find_by_screen_name(opts[:screen_name])
    elsif opts[:id]
      user = TwitterUser.find(options[:id])
    end

    if user.nil?
      # First time we have seen this user. Create a new one.
      user = TwitterUser.new
      lookup_id = opts[:uid] || opts[:screen_name]
    else
      lookup_id = user.uid
    end

    user_info = twitter_api.user(lookup_id)
    return if user_info.nil?

    populate_model_with_user_info(user, user_info)

    # todo has location changed? Re-geocode
    user.save!

    # Create a stats record
    create_user_stats(user_info)

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

  def TwitterUser.create_user_stats(user_info)
    stats = TwitterUserStats.new

    stats.twitter_user_id = user_info.id
    stats.followers = user_info.followers_count
    stats.following = user_info.friends_count

    stats.tweets_per_day = TweetInfo.tweets_per_day(user_info.id)
    stats.replies_per_day = TweetInfo.replies_per_day(user_info.id)
    stats.replies_to_per_day = TweetInfo.replies_to_per_day(user_info.screen_name)

    # todo other stats/classification
    stats.save!
  end

  private

  def TwitterUser.twitter_api
    @@twitter_api ||= TwitterUtils.get_client
  end

end
