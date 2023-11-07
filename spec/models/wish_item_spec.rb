require 'rails_helper'

RSpec.describe WishItem, type: :model do
  subject { build(:wish_item) }
  
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :product }

  #favoritar apenas um vez o produto
  it { is_expected.to validate_uniqueness_of(:product_id).scoped_to(:user_id) }
end
