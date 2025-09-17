class AchievementService
  def initialize(user)
    @user = user
  end
  
  def check_achievements_for_interactive_completion(content_category = nil)
    if content_category
      update_progress_for_category(content_category, 'total_interactives')
    end
    
    update_progress_for_category('general', 'total_interactives')
  end
  
  def check_achievements_for_consecutive_days(days)
    update_progress_for_type('consecutive_days', days)
  end
  
  def check_achievements_for_registration_order
    update_progress_for_type('registration_order')
  end
  
  def check_achievements_for_platform_lifetime
    update_progress_for_type('platform_lifetime')
  end
  
  private
  
  def update_progress_for_category(category, progress_type, value = nil)
    achievements = Achievement.where(category: category, progress_type: progress_type)
    
    achievements.each do |achievement|
      user_achievement = find_or_create_user_achievement(achievement)
      
      case progress_type
      when 'total_interactives'
        increment_progress(user_achievement, 1)
      when 'consecutive_days'
        update_progress(user_achievement, value)
      when 'registration_order'
        if @user.id <= achievement.progress_target
          update_progress(user_achievement, achievement.progress_target)
        else
          update_progress(user_achievement, 0)
        end
      when 'platform_lifetime'
        update_progress(user_achievement, 1)
      end
    end
  end
  
  def update_progress_for_type(progress_type, value = nil)
    achievements = Achievement.where(progress_type: progress_type)
    
    achievements.each do |achievement|
      user_achievement = find_or_create_user_achievement(achievement)
      
      case progress_type
      when 'total_interactives'
        increment_progress(user_achievement, 1)
      when 'consecutive_days'
        update_progress(user_achievement, value)
      when 'registration_order'
        if @user.id <= achievement.progress_target
          update_progress(user_achievement, achievement.progress_target)
        else
          update_progress(user_achievement, 0)
        end
      when 'platform_lifetime'
        update_progress(user_achievement, 1)
      end
    end
  end
  
  def find_or_create_user_achievement(achievement)
    @user.user_achievements.find_or_create_by(achievement: achievement) do |ua|
      ua.progress = 0
    end
  end
  
  def increment_progress(user_achievement, amount)
    user_achievement.increment!(:progress, amount)
    check_completion(user_achievement)
  end
  
  def update_progress(user_achievement, value)
    user_achievement.update!(progress: value)
    check_completion(user_achievement)
  end
  
  def check_completion(user_achievement)
    if user_achievement.progress >= user_achievement.achievement.progress_target && !user_achievement.completed?
      user_achievement.update!(completed_at: Time.current)
    end
  end
end
