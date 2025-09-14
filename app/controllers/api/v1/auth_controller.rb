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
        if user.email_verification_required?
          return render json: { 
            error: 'Email не подтвержден',
            requires_verification: true,
            email: user.email
          }, status: :forbidden
        end
        
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
        user.generate_verification_code!
        VerificationMailer.send_verification_code(user).deliver_now
        
        render json: {
          message: 'Пользователь зарегистрирован. Проверьте email для подтверждения.',
          requires_verification: true,
          email: user.email,
          verification_code: user.verification_code
        }, status: :created
      else
        render json: { 
          error: 'Ошибка регистрации',
          details: user.errors.full_messages 
        }, status: :unprocessable_entity
      end
    end
  end

  def verify_email
    email = params[:email]
    code = params[:code]

    if email.blank? || code.blank?
      return render json: { error: 'Email и код обязательны' }, status: :bad_request
    end

    user = User.find_by(email: email)
    
    unless user
      return render json: { error: 'Пользователь не найден' }, status: :not_found
    end

    if user.verification_code_valid?(code)
      user.verify_email!
      token = encode_token({ user_id: user.id })
      
      render json: {
        message: 'Email успешно подтвержден',
        token: token,
        user: {
          id: user.id,
          email: user.email
        }
      }, status: :ok
    else
      render json: { error: 'Неверный или истекший код' }, status: :unauthorized
    end
  end

  def resend_verification_code
    email = params[:email]

    if email.blank?
      return render json: { error: 'Email обязателен' }, status: :bad_request
    end

    user = User.find_by(email: email)
    
    unless user
      return render json: { error: 'Пользователь не найден' }, status: :not_found
    end

    if user.email_verified?
      return render json: { error: 'Email уже подтвержден' }, status: :bad_request
    end

    user.generate_verification_code!
    VerificationMailer.send_verification_code(user).deliver_now

    render json: {
      message: 'Код подтверждения отправлен повторно',
      verification_code: user.verification_code
    }, status: :ok
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

  def supported_email_domains
    render json: {
      supported_domains: SmtpConfigService.supported_domains,
      message: 'Поддерживаемые почтовые домены для регистрации'
    }, status: :ok
  end
end
