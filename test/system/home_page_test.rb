require "application_system_test_case"

class HomePageTest < ApplicationSystemTestCase
  def setup
    up = Event.create!(title: "Casamento Marina & Rafael", event_type: "wedding",
                       main_date: Date.current + 2.months, start_time: "18:00",
                       place: "Salão Jardim", estimated_guests: 150)
    up.event_owners.create!(name: "Marina Fernandes", phone_number: "85999990000", email: "m@x.com")

    past = Event.create!(title: "Aniversário Solange", event_type: "adult_birthday",
                         main_date: Date.current - 1.month, place: "Buffet Sabor",
                         estimated_guests: 80)
    past.event_owners.create!(name: "Solange Uchoa", phone_number: "85988887777", email: "s@x.com")
  end

  test "home page lists events as responsive cards" do
    page.driver.browser.manage.window.resize_to(1400, 900)
    visit root_path

    assert_selector "h1", text: "Eventos"
    assert_text "Próximos eventos"
    assert_link "Casamento Marina & Rafael"
    assert_text "Eventos passados"
    page.save_screenshot(Rails.root.join("tmp/home_desktop.png").to_s)

    page.driver.browser.manage.window.resize_to(390, 850)
    page.save_screenshot(Rails.root.join("tmp/home_mobile.png").to_s)
  end
end
