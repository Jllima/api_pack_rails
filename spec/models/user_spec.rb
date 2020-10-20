require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  describe 'Create user valid' do
    it { is_expected.to be_valid }
  end

  describe 'Create user invalid' do
    let(:invalid_user) do
      build_stubbed(:user, email: Faker::String.random, password: '123', password_confirmation: '12345')
    end

    it { expect(invalid_user).to be_invalid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to allow_value('mail@mail.com').for(:email) }
    it { is_expected.to_not allow_value('mailmail.com').for(:email) }
    it { is_expected.to_not allow_value('mail@mailcom').for(:email) }
    it { is_expected.to_not allow_value('mailmailcom').for(:email) }
    it { is_expected.to have_secure_password }
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to allow_value('abc123').for(:password) }
    it { is_expected.to_not allow_value('123456').for(:password) }
    it { is_expected.to_not allow_value('abcdef').for(:password) }
    it { is_expected.to_not allow_value('123b').for(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
    it { is_expected.to validate_presence_of(:password_confirmation) }
  end
end
