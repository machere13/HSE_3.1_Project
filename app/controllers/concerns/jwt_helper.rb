module JwtHelper
  extend ActiveSupport::Concern

  JWT_SECRET = Rails.application.secret_key_base

  def encode_token(payload)
    payload[:exp] = 168.hours.from_now.to_i
    JWT.encode(payload, JWT_SECRET, 'HS256')
  end

  def decode_token(token)
    JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256' })[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def auth_header
    request.headers['Authorization']
  end

  def token_from_header
    if auth_header
      auth_header.split(' ')[1]
    end
  end

  def current_user
    token = token_from_header
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    @current_user ||= User.find(decoded_token['user_id'])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def logged_in?
    !!current_user
  end

  def require_auth
    unless logged_in?
      render json: { error: 'Требуется авторизация' }, status: :unauthorized
    end
  end
end
