class BooksController < ApplicationController
  before_action :set_book, only: %i[ show update destroy ]

  # GET /books
  def index
    @books = Book.all.order(rating: :desc, publication_date: :desc)
    @books = @books.map do |book|
      { id:book.id, title: book.title, author_name: book.author.name }
    end
    
    render json: @books
  end

  # GET /books/1
  def show
    render json: @book
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      render json: @book, status: :created, location: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      render json: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy!
  end

  # Report books
  def generate_report
    books = Book.all
    report = []

    books.each do |book|
      author = book.author
      total_books = author.books.count
      highest_rated_book = author.books.order(rating: :desc).first
      published_last_year = author.books.where('publication_date >= ?', 1.year.ago).count

      report << {
        book_title: book.title,
        author_name: author.name,
        total_books: total_books,
        highest_rated_book: highest_rated_book&.title || "N/A",
        published_last_year: published_last_year,
        rating: book.rating,
        status: book.status
      }
    end

    render json: { report: report, generated_at: Time.now.to_s }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.expect(book: [ :title, :author_id, :publication_date, :rating, :status ])
    end
end
