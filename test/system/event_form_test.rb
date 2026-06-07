require "application_system_test_case"

class EventFormTest < ApplicationSystemTestCase
  test "new event form renders, is responsive and adds an owner" do
    page.driver.browser.manage.window.resize_to(1400, 1000)
    visit new_event_path

    assert_selector "h1", text: "Novo evento"
    assert_field "Título do evento"
    assert_selector ".event-owner-fields", count: 1
    page.save_screenshot(Rails.root.join("tmp/event_form_desktop.png").to_s)

    click_button "Adicionar"
    assert_selector ".event-owner-fields", count: 2

    page.driver.browser.manage.window.resize_to(390, 900)
    page.save_screenshot(Rails.root.join("tmp/event_form_mobile.png").to_s)
  end
end
