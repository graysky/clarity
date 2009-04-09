class CreateTweetInfos < ActiveRecord::Migration
  def self.up
    create_table :tweet_infos do |t|
      t.column 'uid', :integer
      t.column 'reply_to_uid', :integer
      t.column 'posted_at', :datetime
    end

    add_index(:tweet_infos, [:uid, :posted_at])
    add_index(:tweet_infos, [:reply_to_uid, :posted_at])
  end

  def self.down
    drop_table :tweet_infos
  end
end
