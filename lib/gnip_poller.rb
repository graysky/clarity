require 'gnip'

# A daemon that pools gnip periodically to retrieve TweetInfos across all twitter users.
# TODO deamonize
class GnipPoller

  def run
    pub = Gnip.publisher.for('twitter')
    attempts = 0

    loop do
      sleep(10)

      begin

        # Get the last bucket we requested. If none, assume 2 minutes ago.
        last_bucket = read_status[:last_bucket] || pub.bucket_for_minutes_ago(2)

        # We always want to be polling the bucket for 1 minute ago.
        # Skip the bucket if we have already handled it.
        next_bucket = pub.bucket_for_minutes_ago(1)

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
              info.in_reply_to = act.tos.first.content[0..20]
            end

            # Save it, but don't sweat it if it fails
            info.save rescue nil
          end
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

GnipPoller.new.run