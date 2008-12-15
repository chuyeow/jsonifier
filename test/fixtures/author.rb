class Author < ActiveRecord::Base
  has_many :posts
  has_many :comments, :through => :posts
end