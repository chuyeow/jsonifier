ActiveRecord::Schema.define(:version => 1) do

  create_table :authors, :force => true do |t|
    t.column :name, :string
  end

  create_table :posts, :force => true do |t|
    t.column :author_id, :integer
    t.column :title, :string
    t.column :body, :text
    t.column :type, :string
    t.column :created_at, :datetime
  end

  create_table :comments, :force => true do |t|
    t.column :post_id, :integer
    t.column :body, :text
    t.column :created_at, :datetime
  end

  create_table :tags, :force => true do |t|
    t.column :name, :string
  end

  create_table :taggings, :force => true do |t|
    t.column :tag_id, :integer
    t.column :taggable_id, :integer
    t.column :taggable_type, :string
  end
end