class ModifyRetweetInfos < ActiveRecord::Migration
  def self.up
    remove_index :retweet_infos, [:retweeter_uid, :posted_at]
    remove_column :retweet_infos, :retweeter_uid
    add_column :retweet_infos, :retweeter, :string, :limit => 20
    add_index :retweet_infos, [:retweeter, :posted_at], :unique => true
  end

  def self.down
    add_column :retweet_infos, :retweeter_uid, :integer
    remove_column :retweet_infos, :retweeter
  end
end
