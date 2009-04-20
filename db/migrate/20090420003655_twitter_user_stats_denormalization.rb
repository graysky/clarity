class TwitterUserStatsDenormalization < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :followers, :integer
    add_column :twitter_users, :following, :integer
    add_column :twitter_users, :classification, :integer
    add_column :twitter_users, :tweets_per_day, :integer
    add_column :twitter_users, :replies_per_day, :integer
    add_column :twitter_users, :replies_to_per_day, :integer
    add_column :twitter_users, :retweets_per_day, :integer
    add_column :twitter_users, :retweeted_per_day, :integer

    add_column :twitter_users, :update_failures, :integer, :default => 0
  end

  def self.down
    remove_column :twitter_users, :followers, :integer
    remove_column :twitter_users, :following, :integer
    remove_column :twitter_users, :classification, :integer
    remove_column :twitter_users, :tweets_per_day, :integer
    remove_column :twitter_users, :replies_per_day, :integer
    remove_column :twitter_users, :replies_to_per_day, :integer
    remove_column :twitter_users, :retweets_per_day, :integer
    remove_column :twitter_users, :retweeted_per_day, :integer

    remove_column :twitter_users, :update_failures, :integer, :default => 0
  end
end
