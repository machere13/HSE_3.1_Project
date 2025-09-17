require "test_helper"

class UserAchievementTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @achievement = Achievement.create!(
      name: "Тестовое достижение",
      description: "Описание тестового достижения",
      category: "general",
      progress_type: "total_interactives",
      progress_target: 10
    )
    @user_achievement = UserAchievement.create!(
      user: @user,
      achievement: @achievement,
      progress: 5
    )
  end

  test "should be valid" do
    assert @user_achievement.valid?
  end

  test "should belong to user" do
    assert_equal @user, @user_achievement.user
  end

  test "should belong to achievement" do
    assert_equal @achievement, @user_achievement.achievement
  end

  test "progress should be present and non-negative" do
    @user_achievement.progress = nil
    assert_not @user_achievement.valid?

    @user_achievement.progress = -1
    assert_not @user_achievement.valid?
  end

  test "should be unique per user and achievement" do
    duplicate = UserAchievement.new(user: @user, achievement: @achievement, progress: 3)
    assert_not duplicate.valid?
  end

  test "completed? should return true when completed_at is present" do
    @user_achievement.update!(completed_at: Time.current)
    assert @user_achievement.completed?
  end

  test "completed? should return false when completed_at is nil" do
    assert_not @user_achievement.completed?
  end

  test "progress_percentage should calculate correctly" do
    assert_equal 50, @user_achievement.progress_percentage
  end

  test "progress_percentage should not exceed 100" do
    @user_achievement.update!(progress: 15)
    assert_equal 100, @user_achievement.progress_percentage
  end

  test "progress_percentage should return 0 when progress_target is zero" do
    @achievement.update!(progress_target: 0)
    assert_equal 0, @user_achievement.progress_percentage
  end
end