class Relationship < ApplicationRecord
  belongs_to :user
  # Userクラスを参照する
  belongs_to :follow, class_name: "User"
end
