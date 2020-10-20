class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true

  validates :email,
            presence: true,
            uniqueness: true,
            format: {
              with: VALID_EMAIL_REGEX,
              message: I18n.t('errors.messages.email_format')
            }

  validates :password,
            length: { minimum: 6 },
            confirmation: true,
            format: {
              with: VALID_PASSWORD_REGEX,
              message: I18n.t('errors.messages.password_format')
            }

  validates :password_confirmation,
            presence: true
end
