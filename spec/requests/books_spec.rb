require 'rails_helper'

RSpec.describe "Books API", type: :request do
  let(:author) { Author.create!(name: "J.K. Rowling") }

  describe "POST /books" do
    it "creates a book" do
      book_params = { title: "Harry Potter", author_id: author.id, publication_date: "2000-07-08" }
      post "/books", params: { book: book_params }  
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["title"]).to eq("Harry Potter")
    end

    it 'returns an error when publication_date is in the future' do
      future_date = Date.today + 1.year
      post "/books", params: { book: { title: "Future Book", author_id: author.id, publication_date: future_date } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["publication_date"]).to include("must be in the past or today")
    end
    
  end

  describe "GET /books" do
    it 'returns books sorted by rating and publication_date' do
      book1 = Book.create!(title: "Book 1", author_id: author.id, publication_date: 3.days.ago, rating: 3)
      book2 = Book.create!(title: "Book 2", author_id: author.id, publication_date: 2.day.ago, rating: 5)
      book3 = Book.create!(title: "Book 3", author_id: author.id, publication_date: 4.days.ago, rating: 3)

      expect {
          get "/books"
      }.to_not raise_error(Bullet::Notification::UnoptimizedQueryError)
      expect(JSON.parse(response.body).map { |b| b["id"] }).to eq([book2.id, book1.id, book3.id])
    end
  end

  describe "GET /generate_report" do
    it "detects N+1 queries with Bullet" do
        authors = create_list(:author, 5)
        authors.each do |author|
            create_list(:book, 5, author: author)
        end
        expect {
            get "/books/generate_report"
        }.to_not raise_error(Bullet::Notification::UnoptimizedQueryError)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to include('generated_at')
        expect(parsed_response['generated_at']).to be_a(String)

        expect(parsed_response).to include('report')
        expect(parsed_response['report']).to be_an(Array)
    end
  end
end
