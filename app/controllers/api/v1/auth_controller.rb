class Api::V1::AuthController < ApplicationController
  include JwtHelper

  def login_or_register
    email = params[:email]
    password = params[:password]

    if email.blank? || password.blank?
      return render json: { error: 'Email и пароль обязательны' }, status: :bad_request
    end

    user = User.find_by(email: email)

    if user
      if user.authenticate(password)
        token = encode_token({ user_id: user.id })
        render json: {
          message: 'Успешный вход',
          token: token,
          user: {
            id: user.id,
            email: user.email
          }
        }, status: :ok
      else
        render json: { error: 'Неверный пароль' }, status: :unauthorized
      end
    else
      user = User.new(email: email, password: password)
      
      if user.save
        token = encode_token({ user_id: user.id })
        render json: {
          message: 'Пользователь успешно зарегистрирован',
          token: token,
          user: {
            id: user.id,
            email: user.email
          }
        }, status: :created
      else
        render json: { 
          error: 'Ошибка регистрации',
          details: user.errors.full_messages 
        }, status: :unprocessable_entity
      end
    end
  end

  def me
    require_auth
    return unless logged_in?

    render json: {
      user: {
        id: current_user.id,
        email: current_user.email
      }
    }, status: :ok
  end
end
