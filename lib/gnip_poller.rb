require 'gnip'

# A daemon that pools gnip periodically to retrieve TweetInfos across all twitter users.

# The gnip gem is broken. There is no way to set a different config than the one
# it expects in the home directory. Fix that here.q1a
module Gnip
  class Config
    def Config.default_path
      File.join("#{RAILS_ROOT}/config", 'gnip.yml')
    end
  end
end


class GnipPoller

  def run
    
    pub = Gnip.publisher.for('twitter')
    attempts = 0
    sleep_time = 1

    loop do
      sleep(sleep_time)

      begin
        puts "start"
        # Get the last bucket we requested. If none, assume 2 minutes ago.
        last_bucket = read_status[:last_bucket] || pub.bucket_for_minutes_ago(2)

        # We always want to be polling the bucket for 1 minute ago.
        # Skip the bucket if we have already handled it.
        next_bucket = pub.bucket_for_minutes_ago(1)

        puts next_bucket + " " + last_bucket
        next if next_bucket == last_bucket

        # We might be more than one minute behind, so calculate the next bucket
        # given the last bucket we processed.
        minutes_ago = (Time.parse(next_bucket) - Time.parse(last_bucket)) / 60
        next_bucket = pub.bucket_for_minutes_ago(minutes_ago)

        puts "Get activity for #{minutes_ago.to_i} minutes ago (#{next_bucket}), attempt #{attempts}"
        activities = pub.notifications(:bucket => next_bucket)

        # Iterate over each activity and write it to the DB as a TweetInfo
        TweetInfo.transaction do
          activities.each do |act|
            info = TweetInfo.new(:uid => act.actors.first.uid, :posted_at => act.at)

            if act.tos && act.tos.length > 0
              info.in_reply_to = act.tos.first.content[0..20].downcase
            end

            # Save it, but don't sweat it if it fails
            info.save rescue nil
          end
        end

        if minutes_ago > 5
          # Catch up faster
          sleep_time = 2
        else
          sleep_time = 10
        end

      rescue Exception => e
        puts e.backtrace
        puts "Error getting notifications: " + e

        # Retry the current bucket if we haven't hit the limit
        if attempts < 5
          attempts += 1
          next
        end
      end

      # Done with this bucket
      puts "done with bucket"
      write_status(:last_bucket => next_bucket)
      attempts = 0
    end

  end

  # Where is the right place for this file? We need something that lives across deploys.
  def filename
    "#{RAILS_ROOT}/tmp/gnip_status.yml"
  end

  def write_status(status)
    File.open(filename, 'w') { |f| f.write(YAML.dump(status)) }
  end

  def read_status
    return {} if !File.exists?(filename)
    File.open(filename, 'r') { |f| YAML.load(f) }
  end

end