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
    has_many :relationships, class_name: "Relationship", foreign_key: "user_id"
    # 自分がフォローしているUser達を表現
    # Followingモデルはないため、relationshipsのfollowカラムを参照する
    has_many :followings, through: :relationships, source: :follow
    # 自分をフォローしているUserへの参照
    has_many :reverses_of_relationship, class_name: "Relationship", foreign_key: "follow_id"
    # 自分をフォローしているUser達を表現
    # Followerモデルはないため、reverse_of_relationshipsのuserカラムを参照する    
    has_many :followers, through: :reverses_of_relationship, source: :user
    
    # 自分がお気に入りしている投稿の参照
    has_many :favorites
    # 自分がお気に入りしている投稿を表現
    has_many :likes, through: :favorites, source: :micropost
    
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
    
    # 投稿をお気に入りに追加する
    def favorite(favorite_micropost)
      self.favorites.find_or_create_by(micropost_id: favorite_micropost.id)
    end
    
    # 投稿のお気に入りを外す
    def unfavorite(favorite_micropost)
      favorite = self.favorites.find_by(micropost_id: favorite_micropost.id)
      favorite.destroy if favorite
    end
    
    # 既にお気に入りに追加されているかを判断
    def favoriting?(favorite_micropost)
      self.likes.include?(favorite_micropost)
    end
    
    # タイムライン用のマイクロポストの取得
    def feed_microposts
      # 自分がフォローしているUserと自分自身のMicropostを取得する
      Micropost.where(user_id: self.following_ids + [self.id])
    end
end