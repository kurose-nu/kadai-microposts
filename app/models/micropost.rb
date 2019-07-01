class Micropost < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true, length: {maximum: 255}
  
  # 投稿をお気に入りしているユーザを参照
  has_many :reverses_of_favorite, class_name: "Favorite", foreign_key: "micropost_id"
  # 投稿をお気に入りしているユーザ達を表現
  has_many :users, through: :reverses_of_favorite
  
end
