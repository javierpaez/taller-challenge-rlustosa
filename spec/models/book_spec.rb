require 'rails_helper'

RSpec.describe Book, type: :model do
  context 'validations' do
    it { should belong_to(:author) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:publication_date) }
    it { should allow_value(0).for(:rating) }
    it { should allow_value(5).for(:rating) }
    it { should_not allow_value(-1).for(:rating) }
    it { should_not allow_value(6).for(:rating) }
    it 'validates inclusion of status in the allowed values' do
        book = Book.new(title: "Test Book", publication_date: Date.today, rating: 4, status: "invalid_status")
        expect(book).not_to be_valid
        expect(book.errors[:status]).to include("is not a valid status")
    end
    it 'is invalid without a title' do
      book = Book.new(publication_date: Date.today)
      expect(book).not_to be_valid
      expect(book.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a publication_date' do
      book = Book.new(title: "Test Book")
      expect(book).not_to be_valid
      expect(book.errors[:publication_date]).to include("can't be blank")
    end
  end

  context 'publication_date validation' do
    let(:author) { Author.create!(name: "J.K. Rowling") }
    it 'is invalid if publication_date is in the future' do
      future_date = Date.today + 1.year
      book = Book.new(title: "Future Book", author_id: author.id, publication_date: future_date)
      expect(book).not_to be_valid
      expect(book.errors[:publication_date]).to include("must be in the past or today")
    end
  end

  context 'status transitions' do
    let(:author) { Author.create!(name: "J.K. Rowling") }
    it 'allows transitioning from available to checked_out' do
      book = Book.create!(title: "Test Book", author_id: author.id, publication_date: Date.today, status: "available")
      book.status = "checked_out"
      expect(book.save).to be true
    end

    it 'does not allow an invalid status' do
      book = Book.create!(title: "Test Book", author_id: author.id, publication_date: Date.today, status: "available")
      book.status = "invalid_status"
      expect(book).not_to be_valid
      expect(book.errors[:status]).to include("is not a valid status")
    end
  end
end
