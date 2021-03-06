class Comment < ActiveRecord::Base
  validates :comment, presence: true, allow_blank: false

  belongs_to :route, inverse_of: :comments
  belongs_to :user, inverse_of: :comments

  def self.most_recent
    order("created_at DESC")
  end
end
