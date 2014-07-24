# == Schema Information
#
# Table name: tag_linkers
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  tagable_id   :integer
#  tagable_type :string(255)
#  tag_id       :integer
#

class TagLinker < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tagable, :polymorphic => true
end
