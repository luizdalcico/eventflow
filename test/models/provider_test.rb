require "test_helper"

class ProviderTest < ActiveSupport::TestCase
  def setup
    @provider = Provider.new(
      provider_type: "photographer",
      name: "Test Studio",
      document: "12.345.678/0001-90",
      contact_name: "John Doe",
      phone_number: "(11) 99999-9999"
    )
  end

  test "should be valid with valid attributes" do
    assert @provider.valid?
  end

  test "should require provider_type" do
    @provider.provider_type = nil
    assert_not @provider.valid?
    assert_includes @provider.errors[:provider_type], "não pode ficar em branco"
  end

  test "should require name" do
    @provider.name = nil
    assert_not @provider.valid?
    assert_includes @provider.errors[:name], "não pode ficar em branco"
  end

  test "document is optional" do
    @provider.document = nil
    assert @provider.valid?

    @provider.document = ""
    assert @provider.valid?
  end

  test "should only accept valid provider types" do
    @provider.provider_type = "invalid_type"
    assert_not @provider.valid?
    assert_includes @provider.errors[:provider_type], "não está incluído na lista"
  end

  test "should accept valid provider types" do
    Provider::PROVIDER_TYPES.each do |type|
      @provider.provider_type = type
      assert @provider.valid?, "#{type} should be valid"
    end
  end

  test "by_type scope should filter by provider type" do
    photographer = Provider.create!(
      provider_type: "photographer",
      name: "Photo Studio",
      document: "11.111.111/0001-11",
      contact_name: "Jane Doe",
      phone_number: "(11) 88888-8888"
    )

    buffet = Provider.create!(
      provider_type: "buffet",
      name: "Catering Co",
      document: "22.222.222/0001-22",
      contact_name: "Bob Smith",
      phone_number: "(11) 77777-7777"
    )

    photographers = Provider.by_type("photographer")
    assert_includes photographers, photographer
    assert_not_includes photographers, buffet
  end
end
