class CreateTweetInfos < ActiveRecord::Migration
  def self.up
    create_table :tweet_infos do |t|
      t.column 'uid', :integer
      t.column 'in_reply_to', :string, :limit => 20
      t.column 'posted_at', :datetime
    end

    # No need for an artificial primary key. Keep this thing light, there will be lots of rows.
    remove_column :tweet_infos, :id

    add_index(:tweet_infos, [:uid, :posted_at], :unique => true)
    add_index(:tweet_infos, [:in_reply_to, :posted_at])
  end

  def self.down
    drop_table :tweet_infos
  end
end
