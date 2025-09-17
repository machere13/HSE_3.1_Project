class UserAchievement < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
  
  validates :progress, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :achievement_id }
  
  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil) }
  
  def completed?
    completed_at.present?
  end
  
  def progress_percentage
    return 0 if achievement.progress_target.zero?
    [progress * 100 / achievement.progress_target, 100].min
  end
end
