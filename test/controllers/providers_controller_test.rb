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

    assert_select "tbody tr", count: 1
    assert_select "tbody tr td", text: /Fotógrafo/
    assert_select "tbody tr td a", text: "Foto & Arte"
    assert_select "tbody tr td", text: /Paulo/
  end

  test "index shows the empty state when there are no providers" do
    @provider.destroy!
    get providers_url
    assert_response :success
    assert_select "table", false
    assert_select "div", text: /Nenhum fornecedor cadastrado ainda/
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
