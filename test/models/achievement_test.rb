require "test_helper"

class AchievementTest < ActiveSupport::TestCase
  def setup
    @achievement = Achievement.new(
      name: "Тестовое достижение",
      description: "Описание тестового достижения",
      category: "general",
      progress_type: "total_interactives",
      progress_target: 10
    )
  end

  test "should be valid" do
    assert @achievement.valid?
  end

  test "name should be present" do
    @achievement.name = nil
    assert_not @achievement.valid?
  end

  test "name should be unique" do
    @achievement.save!
    duplicate_achievement = @achievement.dup
    assert_not duplicate_achievement.valid?
  end

  test "category should be present" do
    @achievement.category = nil
    assert_not @achievement.valid?
  end

  test "progress_type should be present" do
    @achievement.progress_type = nil
    assert_not @achievement.valid?
  end

  test "progress_target should be present and positive" do
    @achievement.progress_target = nil
    assert_not @achievement.valid?

    @achievement.progress_target = 0
    assert_not @achievement.valid?

    @achievement.progress_target = -1
    assert_not @achievement.valid?
  end

  test "should have many user_achievements" do
    @achievement.save!
    user = User.create!(email: "test@example.com", password: "password123")
    user_achievement = @achievement.user_achievements.create!(user: user, progress: 5)
    
    assert_includes @achievement.user_achievements, user_achievement
  end

  test "should have many users through user_achievements" do
    @achievement.save!
    user = User.create!(email: "test@example.com", password: "password123")
    @achievement.user_achievements.create!(user: user, progress: 5)
    
    assert_includes @achievement.users, user
  end
end