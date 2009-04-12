class CreateTwitterUserStats < ActiveRecord::Migration
  def self.up
    create_table :twitter_user_stats do |t|
      t.integer :twitter_user_id
      t.integer :followers
      t.integer :following
      t.integer :classification
      t.integer :tweets_per_day
      t.integer :replies_per_day
      t.integer :replies_to_per_day
      t.integer :retweets_per_day
      t.integer :retweeted_per_day
      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_user_stats
  end
end
