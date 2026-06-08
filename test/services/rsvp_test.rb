require "test_helper"

class RsvpTest < ActiveSupport::TestCase
  def with_env(value)
    previous = ENV["RSVP_SENDING_ENABLED"]
    ENV["RSVP_SENDING_ENABLED"] = value
    yield
  ensure
    ENV["RSVP_SENDING_ENABLED"] = previous
  end

  test "sending_enabled? is false by default (unset)" do
    with_env(nil) { assert_not Rsvp.sending_enabled? }
  end

  test "sending_enabled? is true for truthy values" do
    %w[true 1 t].each do |value|
      with_env(value) { assert Rsvp.sending_enabled?, "expected #{value.inspect} to enable sending" }
    end
  end

  # ActiveModel::Type::Boolean's FALSE_VALUES: only these (plus blank) cast to false.
  test "sending_enabled? is false for falsey values" do
    ["false", "0", "f", "off", ""].each do |value|
      with_env(value) { assert_not Rsvp.sending_enabled?, "expected #{value.inspect} to keep sending off" }
    end
  end
end
