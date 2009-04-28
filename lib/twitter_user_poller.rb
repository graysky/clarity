# Polls the twitter API for updates to users.
# TODO daemonize
class TwitterUserPoller

  # TODO This are settings for testing. Make this configurable by environment? 
  SLEEP_BETWEEN_BATCHES = 10.seconds
  MIN_UPDATE_PERIOD = 1.minute
  BATCH_SIZE = 10
  MAX_UPDATE_FAILURES = 5

  def run

    loop do
      sleep(SLEEP_BETWEEN_BATCHES.to_i)

      begin
        users = TwitterUser.find_users_updated_before((Time.now - MIN_UPDATE_PERIOD),
                                                      BATCH_SIZE, MAX_UPDATE_FAILURES)
    
        users.each do |user|
          begin
            TwitterUser.update_user(:id => user.id, :force => true)
          rescue Exception => e
            # TODO Handle twitter down/unavailable/quota exceptions.
            # Maybe place users in a retry queue?
            puts e
          end
        end

      rescue Exception => e

        puts e.backtrace
        puts e
      end
      
    end

  end

end


