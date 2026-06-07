require "application_system_test_case"

class ProvidersAndNavTest < ApplicationSystemTestCase
  def setup
    @provider = Provider.create!(provider_type: "photographer", name: "Foto & Arte",
                                 contact_name: "Paulo", phone_number: "85999990000",
                                 document: "12345678000190")
  end

  test "providers index renders as a table with type, name and contact" do
    page.driver.browser.manage.window.resize_to(1400, 900)
    visit providers_path
    assert_selector "h1", text: "Fornecedores"

    assert_selector "table"
    # Headers use text-transform: uppercase, so match case-insensitively.
    assert_selector "th", text: /Tipo/i
    assert_selector "th", text: /Fornecedor/i
    assert_selector "th", text: /Contato/i

    within "table" do
      assert_selector "tbody tr", count: 1
      assert_text "Fotógrafo"
      assert_link "Foto & Arte"
      assert_text "Paulo"
    end
    page.save_screenshot(Rails.root.join("tmp/providers_desktop.png").to_s)

    page.driver.browser.manage.window.resize_to(390, 850)
    page.save_screenshot(Rails.root.join("tmp/providers_mobile.png").to_s)
  end

  test "new provider form renders" do
    visit new_provider_path
    assert_selector "h1", text: "Novo fornecedor"
    assert_field "Nome da empresa"
  end

  test "mobile nav shows a hamburger that toggles the menu" do
    page.driver.browser.manage.window.resize_to(390, 850)
    visit root_path

    # Menu fechado: o link mobile não está visível.
    assert_no_selector "[data-nav-target=menu] a", visible: true
    find("button[aria-label=Menu]").click
    assert_selector "[data-nav-target=menu] a", text: "Fornecedores", visible: true
    page.save_screenshot(Rails.root.join("tmp/nav_mobile.png").to_s)
  end
end
