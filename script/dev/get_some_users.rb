api = TwitterUtils.get_client

api.followers('graysky').each { |u| TwitterUser.update_user(:uid => u.id) } 