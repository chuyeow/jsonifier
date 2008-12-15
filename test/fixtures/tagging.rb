class Tagging < ActiveRecord::Base
  belongs_to :tag, :include => :tagging
  belongs_to :taggable, :polymorphic => true
end