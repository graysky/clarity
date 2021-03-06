class RetweetInfo < ActiveRecord::Base

  # TODO What about timezones? Everything in UTC?
  def RetweetInfo.retweeted_per_day(username, from_days = 7)
    to = Date.today - 1.second
    from = Date.today - from_days

    total = count(:conditions => ["retweeted=? and posted_at >= ? and posted_at <= ?", username, from, to])
    ((total / from_days.to_f) * 100).to_i
  end

  def RetweetInfo.retweets_per_day(retweeter, from_days = 7)
    to = Date.today - 1.second
    from = Date.today - from_days

    total = count(:conditions => ["retweeter=? and posted_at >= ? and posted_at <= ?", retweeter, from, to])
    ((total / from_days.to_f) * 100).to_i
  end

  # Returns the username of the retweeted user if it is a valid retweet.
  # Otherwise returns nil.
  def RetweetInfo.get_retweeted_from_msg(msg)

    # people do weird things with quotes
    msg.gsub!("&quot;", " ")

    words = msg.split(' ')
    index = 0

    # Weird case I've seen: No space after RT, like "RT@gary", or "RT:@gary"
    if words[0].upcase.starts_with?('RT@')
      retweeted = words[0].from(3)
      return cleanse_retweeted_name(retweeted)
    elsif
      words[0].upcase.starts_with?('RT:@')
      retweeted = words[0].from(4)
      return cleanse_retweeted_name(retweeted)
    end

    words.each do |word|
      if word.upcase == 'RT' || word.upcase == 'RT:'
        # Is the next word a username? If so consider it a retweet.
        next_word = words[index + 1]

        if next_word && next_word.starts_with?('@')
          retweeted = next_word.from(1)

          return cleanse_retweeted_name(retweeted)
        end
      end

      index += 1
    end


    return nil
  end

  private

  def RetweetInfo.cleanse_retweeted_name(retweeted)
    index = retweeted.index(':')
    if index
      retweeted = retweeted.to(index - 1)
    end

    retweeted
  end

end
