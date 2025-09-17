require "test_helper"

class Api::V1::AchievementsTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com", password: "password123", email_verified: true)
    @token = JwtHelper.encode({ user_id: @user.id })
    
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

  test "should get all achievements" do
    get "/api/v1/achievements"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal @achievement.name, json_response.first["name"]
  end

  test "should get user achievements" do
    get "/api/v1/achievements/my", headers: { "Authorization" => "Bearer #{@token}" }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_includes json_response.keys, "completed"
    assert_includes json_response.keys, "in_progress"
    assert_equal 1, json_response["in_progress"].length
  end

  test "should get achievements by category" do
    get "/api/v1/achievements/by_category?category=general"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal "general", json_response.first["category"]
  end

  test "should return 400 for invalid category" do
    get "/api/v1/achievements/by_category?category=invalid"
    assert_response :bad_request
  end

  test "should require authentication for user achievements" do
    get "/api/v1/achievements/my"
    assert_response :unauthorized
  end

  test "should return 401 for invalid token" do
    get "/api/v1/achievements/my", headers: { "Authorization" => "Bearer invalid_token" }
    assert_response :unauthorized
  end
end
