require 'json'
require 'date'
require 'securerandom'

class ExpenseTracker
  USERS_FILE = 'users.json'
  EXPENSES_FILE = 'expenses.json'

  def initialize
    @current_user = nil
    @users = load_users
    @expenses = load_expenses
  end

  def load_users
    if File.exist?(USERS_FILE)
      file = File.read(USERS_FILE)
      JSON.parse(file, symbolize_names: true)
    else
      []
    end
  end

  def save_users
    File.open(USERS_FILE, 'w') do |file|
      file.write(JSON.pretty_generate(@users))
    end
  end

  def load_expenses
    if File.exist?(EXPENSES_FILE)
      file = File.read(EXPENSES_FILE)
      JSON.parse(file, symbolize_names: true)
    else
      []
    end
  end

  def save_expenses
    File.open(EXPENSES_FILE, 'w') do |file|
      file.write(JSON.pretty_generate(@expenses))
    end
  end

  def sign_up
    puts "Enter a username:"
    username = gets.chomp
    puts "Enter a password:"
    password = gets.chomp

    if @users.any? { |user| user[:username] == username }
      puts "Username already exists. Please try again."
    else
      user = { id: SecureRandom.uuid, username: username, password: password }
      @users << user
      save_users
      puts "User signed up successfully!"
    end
  end

  def login
    puts "Enter your username:"
    username = gets.chomp
    puts "Enter your password:"
    password = gets.chomp

    user = @users.find { |u| u[:username] == username && u[:password] == password }

    if user
      @current_user = user

      puts "login Successful!"
    else
      puts "Invalid username or password. Please try again."
    end
  end

  def add_expense(description, amount, date)
    expense = { id: SecureRandom.uuid, user_id: @current_user[:id], description: description, amount: amount.to_f, date: date.to_s }
    @expenses << expense
    save_expenses
  end

  def remove_expense(id)
    @expenses.reject! { |expense| expense[:id] == id && expense[:user_id] == @current_user[:id] }
    save_expenses
  end

  def edit_expense(id, description, amount, date)
    expense = @expenses.find { |expense| expense[:id] == id && expense[:user_id] == @current_user[:id] }
    if expense
      expense[:description] = description
      expense[:amount] = amount.to_f
      expense[:date] = date.to_s
      save_expenses
    else
      puts "Expense not found."
    end
  end

  def display_expenses
    puts "Expenses:"
    user_expenses = @expenses.select { |expense| expense[:user_id] == @current_user[:id] }
    user_expenses.each_with_index do |expense, index|
      puts "#{index + 1}. #{expense[:date]} - #{expense[:description]}: $#{'%.2f' % expense[:amount]} (ID: #{expense[:id]})"
    end
    total_amount = user_expenses.sum { |expense| expense[:amount] }
    puts "Total: $#{'%.2f' % total_amount}"
  end

  def start
    loop do
      puts "1. Sign Up"
      puts "2. Login"
      puts "3. Exit"
      choice = gets.chomp.to_i

      case choice
      when 1
        sign_up
      when 2
        login
        user_menu if @current_user
      when 3
        break
      else
        puts "Invalid choice. Please try again."
      end
    end
  end

  def user_menu
    loop do
      puts "1. Add Expense"
      puts "2. Remove Expense"
      puts "3. Edit Expense"
      puts "4. Display Expenses"
      puts "5. Logout"
      choice = gets.chomp.to_i

      case choice
      when 1
        puts "Enter description:"
        description = gets.chomp
        puts "Enter amount:"
        amount = gets.chomp.to_f
        puts "Enter date (YYYY-MM-DD):"
        date = gets.chomp

        begin
          date = Date.parse(date)
          add_expense(description, amount, date)
          puts "Expense added successfully."
        rescue ArgumentError
          puts "Invalid date format. Please enter the date in YYYY-MM-DD format."
        end
      when 2
        puts "Enter expense ID to remove:"
        id = gets.chomp
        remove_expense(id)
        puts "Expense removed successfully."
      when 3
        puts "Enter expense ID to edit:"
        id = gets.chomp
        puts "Enter new description:"
        description = gets.chomp
        puts "Enter new amount:"
        amount = gets.chomp.to_f
        puts "Enter new date (YYYY-MM-DD):"
        date = gets.chomp

        begin
          date = Date.parse(date)
          edit_expense(id, description, amount, date)
          puts "Expense edited successfully."
        rescue ArgumentError
          puts "Invalid date format. Please enter the date in YYYY-MM-DD format."
        end
      when 4
        display_expenses
      when 5
        @current_user = nil
        break
      else
        puts "Invalid choice. Please try again."
      end
    end
  end
end

tracker = ExpenseTracker.new
tracker.start
