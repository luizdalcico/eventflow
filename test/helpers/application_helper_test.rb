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

  test "breadcrumbs renders a labelled nav with an ordered list" do
    html = breadcrumbs([ "Eventos", "/events" ], [ "Atual", nil ])
    assert_includes html, %(<nav aria-label="Breadcrumb")
    assert_includes html, "<ol"
  end

  test "breadcrumbs links every crumb except the last" do
    html = breadcrumbs([ "Eventos", "/events" ], [ "Convidados", nil ])
    assert_includes html, %(href="/events")
    assert_includes html, ">Eventos</a>"
    # The current (last) crumb is plain text, marked as the current page.
    assert_includes html, %(aria-current="page")
    assert_includes html, ">Convidados</span>"
  end

  test "breadcrumbs renders an intermediate crumb with a nil path as plain text" do
    html = breadcrumbs([ "Eventos", nil ], [ "Convidados", "/events/1/guests" ], [ "Atual", nil ])
    # The nil-path intermediate crumb must not become a link.
    refute_includes html, ">Eventos</a>"
    assert_includes html, ">Eventos</span>"
    assert_includes html, %(href="/events/1/guests")
  end

  test "breadcrumbs drops crumbs with a blank label" do
    html = breadcrumbs([ "", "/events" ], [ "Atual", nil ])
    assert_includes html, "Atual"
    refute_includes html, "/events"
  end

  test "breadcrumbs renders nothing when there are no crumbs" do
    assert_equal "", breadcrumbs.strip
  end

  test "event_crumb_label uses the event title when present" do
    event = Event.new(title: "Casamento da Ana", event_type: "wedding")
    assert_equal "Casamento da Ana", event_crumb_label(event)
  end

  test "event_crumb_label falls back to the translated type when the title is blank" do
    event = Event.new(title: "", event_type: "wedding")
    assert_equal "Casamento", event_crumb_label(event)
  end
end
