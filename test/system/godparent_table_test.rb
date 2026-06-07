require "application_system_test_case"

class GodparentTableTest < ApplicationSystemTestCase
  def setup
    @event = Event.create!(title: "Casamento Teste", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
    @list = @event.create_godparent_list!(expires_at: 1.week.from_now)
    m1 = @event.godparents.create!(role: "madrinha", position: 1,
                                   name: "Marina", phone_number: "85999990000", side: "noivo",
                                   relationship: "casados", relation: "irmao")
    p1 = @event.godparents.create!(role: "padrinho", position: 1, name: "Rafael")
    m1.update!(pair_id: p1.id); p1.update!(pair_id: m1.id)

    m2 = @event.godparents.create!(role: "madrinha", position: 2, name: "Ana")
    p2 = @event.godparents.create!(role: "padrinho", position: 2, name: "Pedro", relation: "amigo")
    m2.update!(pair_id: p2.id); p2.update!(pair_id: m2.id)
  end

  test "renders the HTML Excel-like table (desktop) and stacks on mobile" do
    page.driver.browser.manage.window.resize_to(1400, 900)
    visit godparent_list_path(@list.token)

    assert_selector "table"
    assert_selector "th", text: "Lado"
    assert_selector "th", text: "Os padrinhos são"
    assert_field "pair[madrinha][name]", with: "Marina"
    assert_field "pair[padrinho][name]", with: "Rafael"

    page.save_screenshot(Rails.root.join("tmp/padrinhos_desktop.png").to_s)

    page.driver.browser.manage.window.resize_to(390, 850)
    page.save_screenshot(Rails.root.join("tmp/padrinhos_mobile_collapsed.png").to_s)

    # Expande o primeiro par (toca no resumo) e confere que os campos aparecem.
    find("td", text: "Marina").click
    assert_field "pair[madrinha][name]", with: "Marina"
    page.save_screenshot(Rails.root.join("tmp/padrinhos_mobile_expanded.png").to_s)
  end
end
