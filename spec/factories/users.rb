FactoryBot.define do
  password = 'abc123'

  factory :user do
    name { Faker::Name.name }
    username { Faker::Internet.username }
    email { Faker::Internet.email }
    password { password }
    password_confirmation { password }
  end
end
