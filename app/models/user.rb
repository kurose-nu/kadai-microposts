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
    # 自分がフォローしているユーザへの参照
    has_many :relationships
    # 自分がフォローしているUser達を表現
    # Followingモデルはないため、relationshipsのfollowカラムを参照する
    has_many :followings, through: :relationships, source: :follow
    # 自分をフォローしているUserへの参照
    has_many :reverses_of_relationship, class_name: "Relationship", foreign_key: "follow_id"
    # 自分をフォローしているUser達を表現
    # Followerモデルはないため、reverse_of_relationshipsのuserカラムを参照する    
    has_many :followers, through: :reverses_of_relationship, source: :user
    
    # ユーザをフォローする
    def follow(other_user)
      # 自分自身をフォローしないようにする
      unless self == other_user
      # 既にフォローしているときはRelationを返し（重複してフォローしない）、
      # そうでなければフォロー関係を保存
        self.relationships.find_or_create_by(follow_id: other_user.id)
      end
    end
    
    # フォローを外す
    def unfollow(other_user)
      relationship = self.relationships.find_by(follow_id: other_user.id)
      relationship.destroy if relationship
    end
    
    # 既にフォローしているかどうかを判断する
    def following?(other_user)
      # self.followings　⇨　フォローしているユーザを取得
      # include?(other_user)　⇨　other_userが含まれているか
      self.followings.include?(other_user)
    end
    
    # タイムライン用のマイクロポストの取得
    def feed_microposts
      # 自分がフォローしているUserと自分自身のMicropostを取得する
      Micropost.where(user_id: self.following_ids + [self.id])
    end
end