class Product < ApplicationRecord
  include LikeSearchable
  include Paginatable

  belongs_to :productable, polymorphic: true
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :featured, presence: true, if: -> { featured.nil? }
  
  validates :image, presence: true
  has_one_attached :image

  validates :status, presence: true
  enum status: { available: 1, unavailable: 2 }

  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories #through = através

  has_many :wish_items
  
end
