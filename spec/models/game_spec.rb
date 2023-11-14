require 'rails_helper'

RSpec.describe Game, type: :model do
  it { is_expected.to validate_presence_of(:mode) }
  it { is_expected.to define_enum_for(:mode).with_values({ pvp: 1, pve: 2, both: 3 }) }
  it { is_expected.to validate_presence_of(:release_date) }
  it { is_expected.to validate_presence_of(:developer) }

  it { is_expected.to belong_to :system_requirement } 
  it { is_expected.to have_one :product } 
  it { is_expected.to have_many :licenses }

  it_has_behavior_of "like searchable concern", :game, :developer

  #a chamada de um método 'ship!' que deve chamar o 'job' com o 'item de pedido'
  it "#ship! must schedule job AlocateLicenseJob sending Line Item" do
    subject.product = create(:product)
    line_item = create(:line_item, product: subject.product)
    #espera que receba o 'line_item' no 'ship!'
    expect do
      subject.ship!(line_item)
      #faça o agendamento do 'job' passando pra ele o 'line_item'
    end.to have_enqueued_job(Admin::AlocateLicenseJob).with(line_item)
  end 
end
