require 'twitter'

# A deamon that polls twitter search for tweets that are likely to be retweets.
# Does not currently pick up where it left off after restarting.

class RetweetPoller

  def run

    since_id = 0
    sleep_time = 10

    loop do
      sleep(sleep_time)

      begin
        search = Twitter::Search.new('RT ')
        search.per_page(100)
        search.since(since_id) if since_id > 0

        results = search.fetch(true).results()

        if results.size == 100
          # Get up to 200 retweets. Can't imagine more than that in 10 seconds (for now)
          results += search.page(2).fetch(true).results()
        end

        results.each do |result|
          since_id = [result.id, since_id].max

          # Is this actually a retweet?
          retweeted = RetweetInfo.get_retweeted_from_msg(result.text)
          #puts result.text if retweeted.nil?
          next if retweeted.nil?

          info = RetweetInfo.new
          info.retweeter_uid = result.from_user_id
          info.retweeted = retweeted
          info.posted_at = result.created_at
          info.tweet_id = result.id
          info.save rescue nil
        end

        sleep_time = 10

      rescue Exception => e
        puts e.backtrace
        puts "Error during retweet search: #{e}"
        sleep_time = 4
      end
    end
  end

end
