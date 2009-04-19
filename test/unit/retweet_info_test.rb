require 'test_helper'

class RetweetInfoTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "get_retweeted_from_msg" do
    assert RetweetInfo.get_retweeted_from_msg("asdfasd").nil?
    assert RetweetInfo.get_retweeted_from_msg("RT foo").nil?
    assert RetweetInfo.get_retweeted_from_msg("@gary RT mike").nil?
    assert RetweetInfo.get_retweeted_from_msg("RT @foo") == "foo"
    assert RetweetInfo.get_retweeted_from_msg("xxx RT: @foo: xxx") == "foo"
    assert RetweetInfo.get_retweeted_from_msg("RT@foo asdf") == "foo"
    assert RetweetInfo.get_retweeted_from_msg("RT:@foo asdf") == "foo"
    assert RetweetInfo.get_retweeted_from_msg("RT @foo:msg and stuff") == "foo"
    assert RetweetInfo.get_retweeted_from_msg("RT @foo&quot;msg&quot;") == "foo"
  end
end
