class User < ApplicationRecord
    # レコードを保存する前に、文字を全て小文字に変換する
    before_save { self.email.downcase! }
    validates :name, presence: true, length: {maximum: 50}
    validates :email, presence: true, length: { maximum: 255 },
                    # 入力されるメールアドレスが正しい形式なっているか判断
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    # 重複を許さず、大文字と小文字を区別しない
                    uniqueness: { case_sensitive: false }
    has_secure_password
    
    has_many :microposts
end
