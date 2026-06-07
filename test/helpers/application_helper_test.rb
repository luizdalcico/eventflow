require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "whatsapp_url prefixes 55 for a plain mobile number" do
    assert_equal "https://wa.me/5511999998888", whatsapp_url("11999998888")
  end

  test "whatsapp_url keeps an existing 55 DDI" do
    assert_equal "https://wa.me/5511999998888", whatsapp_url("5511999998888")
  end

  test "whatsapp_url strips punctuation from a formatted number" do
    assert_equal "https://wa.me/5511999998888", whatsapp_url("(11) 99999-8888")
  end

  test "whatsapp_url returns nil for blank input" do
    assert_nil whatsapp_url("")
    assert_nil whatsapp_url(nil)
  end

  test "whatsapp_link renders an anchor pointing to wa.me" do
    html = whatsapp_link("11999998888")
    assert_includes html, %(href="https://wa.me/5511999998888")
    assert_includes html, %(target="_blank")
    assert_includes html, "<svg"
  end

  test "whatsapp_link returns nil when there is no usable number" do
    assert_nil whatsapp_link("")
    assert_nil whatsapp_link(nil)
  end
end
