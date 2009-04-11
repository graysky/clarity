class CreateTwitterUsers < ActiveRecord::Migration
  def self.up
    create_table :twitter_users do |t|
      t.integer :uid
      t.string :screen_name, :limit => 20
      t.string :name, :limit => 20
      t.string :location
      t.string :description
      t.string :profile_image_url
      t.string :url
      t.column "lat", :decimal, :precision => 15, :scale => 10
      t.column "lng", :decimal, :precision => 15, :scale => 10    

      t.timestamps
    end

    add_index(:twitter_users, :uid)
    add_index(:twitter_users, :screen_name)
  end

  def self.down
    drop_table :twitter_users
  end
end
