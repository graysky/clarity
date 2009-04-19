class CreateRetweetInfos < ActiveRecord::Migration
  def self.up
    create_table :retweet_infos do |t|
      t.column 'retweeter_uid', :integer
      t.column 'retweeted', :string, :limit => 20
      t.column 'tweet_id', :integer
      t.column 'posted_at', :datetime   
    end

    remove_column :retweet_infos, :id

    add_index :retweet_infos, [:retweeter_uid, :posted_at], :unique => true
    add_index :retweet_infos, [:retweeted, :posted_at]
    add_index :retweet_infos, [:tweet_id, :posted_at]
  end

  def self.down
    drop_table :retweet_infos
  end
end
