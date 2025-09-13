class Api::V1::AuthController < ApplicationController
  def login_or_register
    email = params[:email]
    password = params[:password]

    # Валидация входных данных
    if email.blank? || password.blank?
      return render json: { error: 'Email и пароль обязательны' }, status: :bad_request
    end

    # Ищем пользователя по email
    user = User.find_by(email: email)

    if user
      # Пользователь существует - проверяем пароль
      if user.authenticate(password)
        render json: {
          message: 'Успешный вход',
          user: {
            id: user.id,
            email: user.email
          }
        }, status: :ok
      else
        render json: { error: 'Неверный пароль' }, status: :unauthorized
      end
    else
      # Пользователь не существует - создаем нового
      user = User.new(email: email, password: password)
      
      if user.save
        render json: {
          message: 'Пользователь успешно зарегистрирован',
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
end
