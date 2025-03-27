FactoryBot.define do
    factory :book do
      title { "Sample Book" }
      publication_date { Faker::Date.backward(days: 365 * 2) }
      rating { rand(0..5) }
      status { "available" }
      association :author
    end
  end
  