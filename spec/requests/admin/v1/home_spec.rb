require "rails_helper"

describe "Home", type: :request do
  let(:user) { create(:user) }

  it "Tests Home" do
    get '/admin/v1/home', headers: auth_header(user) #o método auth_header(user) inclui cabeçalhos de autenticação
    expect(body_json).to eq({ 'message' => 'Uhul!' })
  end

  it "Tests Home" do
    get '/admin/v1/home', headers: auth_header(user)
    expect(response).to have_http_status(:ok)
  end    
end