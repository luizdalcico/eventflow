require "application_system_test_case"

class EventProvidersTest < ApplicationSystemTestCase
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
    @provider = Provider.create!(provider_type: "photographer", name: "Foto & Arte",
                                 contact_name: "Paulo", phone_number: "85999990000", document: "12345678000190")
  end

  test "associate a provider to the event and persist details" do
    page.driver.browser.manage.window.resize_to(1200, 900)
    visit event_event_providers_path(@event)

    assert_selector "h1", text: "Fornecedores do evento"
    assert_text "Nenhum fornecedor associado"

    select "Fotógrafo — Foto & Arte", from: "provider_id"
    click_button "Adicionar ao evento"

    assert_link "Foto & Arte"
    assert_equal 1, @event.event_providers.count

    # The listing is a table with type, provider and contact.
    # Headers use text-transform: uppercase, so match case-insensitively.
    assert_selector "th", text: /Tipo/i
    assert_selector "th", text: /Fornecedor/i
    assert_selector "th", text: /Contato/i
    within "#event_providers" do
      assert_selector "tr", count: 1
      assert_text "Fotógrafo"
      assert_text "Paulo"
    end

    fill_in "event_provider[value]", with: "R$ 5.000"
    find("h1").click # blur para disparar o auto-save

    # auto-save (debounce) persiste no custom_details
    ep = @event.event_providers.first
    saved = false
    12.times { break (saved = true) if ep.reload.custom_detail("value") == "R$ 5.000"; sleep 0.25 }
    assert saved, "valor deveria ter sido salvo via auto-save"
    page.save_screenshot(Rails.root.join("tmp/event_providers_desktop.png").to_s)
  end
end
