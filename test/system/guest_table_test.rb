require "application_system_test_case"

class GuestTableTest < ApplicationSystemTestCase
  def setup
    @event = Event.create!(title: "Casamento Teste", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
    @event.guests.create!(name: "Arnóbio e Tânia", party_size: 2,
                          phone_number: "85999990001", rsvp_status: "confirmed", notes: "Mesa 1")
    @event.guests.create!(name: "Carlos Souza", party_size: 1, phone_number: "85988887777")
  end

  test "renders the editable guest table (desktop) and stacks on mobile" do
    page.driver.browser.manage.window.resize_to(1400, 900)
    visit event_guests_path(@event)

    assert_selector "table"
    assert_selector "th", text: "Pessoas"
    assert_field "guest[name]", with: "Arnóbio e Tânia"
    assert_text "Confirmados"
    page.save_screenshot(Rails.root.join("tmp/convidados_desktop.png").to_s)

    page.driver.browser.manage.window.resize_to(390, 850)
    # Colapsado no mobile: o resumo mostra o nome e a quantidade.
    assert_text "Arnóbio e Tânia"
    assert_text "2 pessoas"
    page.save_screenshot(Rails.root.join("tmp/convidados_mobile.png").to_s)
  end

  test "the all-send button opens the custom confirm modal when sending is enabled" do
    previous = ENV["RSVP_SENDING_ENABLED"]
    ENV["RSVP_SENDING_ENABLED"] = "true"
    page.driver.browser.manage.window.resize_to(1400, 900)
    visit event_guests_path(@event)
    click_button "📨 Enviar RSVP para todos"
    assert_selector "dialog[open]", wait: 5
    assert_text "Enviar o convite RSVP para TODOS"
    page.save_screenshot(Rails.root.join("tmp/modal.png").to_s)
  ensure
    ENV["RSVP_SENDING_ENABLED"] = previous
  end

  test "shows the awaiting-approval hint while sending is disabled (button is a placeholder)" do
    page.driver.browser.manage.window.resize_to(1400, 900)
    visit event_guests_path(@event)
    assert_button "📨 Enviar RSVP para todos" # botão visível
    assert_text "aguardando aprovação do WhatsApp Business"
  end
end
