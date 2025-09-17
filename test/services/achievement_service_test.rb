require "test_helper"

class AchievementServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @service = AchievementService.new(@user)
    
    @interactive_achievement = Achievement.create!(
      name: "Интерактивное достижение",
      description: "Пройдите интерактив",
      category: "general",
      progress_type: "total_interactives",
      progress_target: 5
    )
    
    @consecutive_achievement = Achievement.create!(
      name: "Достижение по дням",
      description: "Просматривайте контент подряд",
      category: "content_viewing",
      progress_type: "consecutive_days",
      progress_target: 7
    )
  end

  test "should create user achievement when checking interactive completion" do
    @service.check_achievements_for_interactive_completion
    
    user_achievement = @user.user_achievements.find_by(achievement: @interactive_achievement)
    assert_not_nil user_achievement
    assert_equal 1, user_achievement.progress
  end

  test "should increment progress for interactive achievements" do
    @service.check_achievements_for_interactive_completion
    @service.check_achievements_for_interactive_completion
    
    user_achievement = @user.user_achievements.find_by(achievement: @interactive_achievement)
    assert_equal 2, user_achievement.progress
  end

  test "should complete achievement when target is reached" do
    @service.check_achievements_for_interactive_completion
    @service.check_achievements_for_interactive_completion
    @service.check_achievements_for_interactive_completion
    @service.check_achievements_for_interactive_completion
    @service.check_achievements_for_interactive_completion
    
    user_achievement = @user.user_achievements.find_by(achievement: @interactive_achievement)
    assert user_achievement.completed?
    assert_not_nil user_achievement.completed_at
  end

  test "should update progress for consecutive days" do
    @service.check_achievements_for_consecutive_days(5)
    
    user_achievement = @user.user_achievements.find_by(achievement: @consecutive_achievement)
    assert_not_nil user_achievement
    assert_equal 5, user_achievement.progress
  end

  test "should complete consecutive days achievement when target is reached" do
    @service.check_achievements_for_consecutive_days(7)
    
    user_achievement = @user.user_achievements.find_by(achievement: @consecutive_achievement)
    assert user_achievement.completed?
  end

  test "should not complete achievement when target is not reached" do
    @service.check_achievements_for_consecutive_days(3)
    
    user_achievement = @user.user_achievements.find_by(achievement: @consecutive_achievement)
    assert_not user_achievement.completed?
    assert_nil user_achievement.completed_at
  end
end
