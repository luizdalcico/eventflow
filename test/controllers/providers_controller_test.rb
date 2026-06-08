require "test_helper"

class ProvidersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Provider.create!(provider_type: "photographer", name: "Foto & Arte",
                                 contact_name: "Paulo", phone_number: "85999990000",
                                 document: "12345678000190")
  end

  test "index renders providers as a table with type, name and contact" do
    get providers_url
    assert_response :success

    assert_select "table"
    assert_select "th", text: "Tipo"
    assert_select "th", text: "Fornecedor"
    assert_select "th", text: "Contato"

    assert_select "[data-tabs-name=todos] tbody tr a", text: "Foto & Arte"
    assert_select "[data-tabs-name=todos] tbody tr td", text: /Fotógrafo/
    assert_select "[data-tabs-name=todos] tbody tr td", text: /Paulo/
  end

  test "index renders the tabs navigation" do
    get providers_url
    assert_response :success
    assert_select "[data-testid=tab-todos]"
    assert_select "[data-testid=tab-por-tipo]"
  end

  test "index shows the empty state when there are no providers" do
    @provider.destroy!
    get providers_url
    assert_response :success
    assert_select "table", false
    assert_select "div", text: /Nenhum fornecedor cadastrado ainda/
  end

  test "index searches by company name" do
    other = Provider.create!(provider_type: "buffet", name: "Sabor & Cia",
                             contact_name: "Ana", phone_number: "85988887777", document: "")
    get providers_url(q: "Foto")
    assert_response :success
    assert_select "[data-tabs-name=todos] tbody tr a", text: "Foto & Arte"
    assert_select "[data-tabs-name=todos] tbody tr a", { text: other.name, count: 0 }
  end

  test "index searches by contact name" do
    Provider.create!(provider_type: "buffet", name: "Sabor & Cia",
                     contact_name: "Ana", phone_number: "85988887777", document: "")
    get providers_url(q: "Paulo")
    assert_response :success
    assert_select "[data-tabs-name=todos] tbody tr a", text: "Foto & Arte"
    assert_select "[data-tabs-name=todos] tbody tr a", { text: "Sabor & Cia", count: 0 }
  end

  test "index filters by type" do
    Provider.create!(provider_type: "buffet", name: "Sabor & Cia",
                     contact_name: "Ana", phone_number: "85988887777", document: "")
    get providers_url(type: "buffet")
    assert_response :success
    assert_select "[data-tabs-name=todos] tbody tr a", text: "Sabor & Cia"
    assert_select "[data-tabs-name=todos] tbody tr a", { text: "Foto & Arte", count: 0 }
  end

  test "index ignores an unknown type filter" do
    get providers_url(type: "not-a-real-type")
    assert_response :success
    assert_select "[data-tabs-name=todos] tbody tr a", text: "Foto & Arte"
  end

  test "index combines type filter and search" do
    Provider.create!(provider_type: "buffet", name: "Sabor & Cia",
                     contact_name: "Paulo", phone_number: "85988887777", document: "")
    get providers_url(type: "buffet", q: "Paulo")
    assert_response :success
    assert_select "[data-tabs-name=todos] tbody tr a", text: "Sabor & Cia"
    assert_select "[data-tabs-name=todos] tbody tr a", { text: "Foto & Arte", count: 0 }
  end

  test "index shows a no-results message when filters match nothing" do
    get providers_url(q: "Inexistente")
    assert_response :success
    assert_select "table", false
    assert_select "div", text: /Nenhum fornecedor encontrado para os filtros aplicados/
  end

  test "show renders the provider" do
    get provider_url(@provider)
    assert_response :success
    assert_select "h1", text: "Foto & Arte"
  end

  test "new renders the form" do
    get new_provider_url
    assert_response :success
    assert_select "h1", text: "Novo fornecedor"
  end

  test "create persists a provider" do
    assert_difference("Provider.count", 1) do
      post providers_url, params: { provider: {
        provider_type: "buffet", name: "Sabor & Cia",
        contact_name: "Ana", phone_number: "85988887777", document: ""
      } }
    end
    created = Provider.order(:created_at).last
    assert_equal "Sabor & Cia", created.name
    assert_redirected_to provider_url(created)
  end

  test "update changes the provider" do
    patch provider_url(@provider), params: { provider: { name: "Foto & Arte Studio" } }
    assert_redirected_to provider_url(@provider)
    assert_equal "Foto & Arte Studio", @provider.reload.name
  end

  test "destroy removes the provider" do
    assert_difference("Provider.count", -1) do
      delete provider_url(@provider)
    end
    assert_redirected_to providers_url
  end
end
