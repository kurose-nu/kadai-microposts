class CreateRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :relationships do |t|
      t.references :user, foreign_key: true
      # followテーブルはなく、userテーブルを参照する
      t.references :follow, foreign_key: {to_table: :users}

      t.timestamps
      
      # フォローIDとフォロアーIDが重複しないように設定
      t.index [:user_id, :follow_id], unique: true
    end
  end
end
