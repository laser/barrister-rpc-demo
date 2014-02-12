require 'colorize'
require 'pry'

session_over = false

#
# Game Loop
#

module ViewUtils
  module_function

  DATA_WIDTHS  = [5, 20, 20, 20]
  NEWLINE      = "\n"
  ROW_TEMPLATE = "| %s | %s | %s | %s |" + NEWLINE
  DIVIDER      = "+#{"-" * (DATA_WIDTHS.reduce(:+) + ROW_TEMPLATE.size - (DATA_WIDTHS.size * 2) - NEWLINE.size - 2)}+" + NEWLINE

  def as_column_template(width)
    "%-#{width}.#{width}s"
  end

  def as_interpolatable(data)
    raise unless data.size == DATA_WIDTHS.size

    data.zip(DATA_WIDTHS).map do |(item, width)|
      sprintf(as_column_template(width), item)
    end
  end

  def render_help
    <<-eos
    Supported commands:

    list            Show the list of users
    edit [id]       Edit a user
    create          Create a user
    delete [id]     Delete a user
    quit, exit      Exit the program

    eos
  end

  def render_users(users)
    s  = DIVIDER
    s += ROW_TEMPLATE % as_interpolatable(['id', 'full_name', 'email', 'phone_number'])
    s += DIVIDER
    s += users.map { |user| ViewUtils.render_user user } .join('')
    s += DIVIDER
  end

  def render_user(user)
    ROW_TEMPLATE % as_interpolatable([user['id'], user['full_name'], user['email'], user['phone_number']])
  end
end

until session_over do
  puts
  puts 'What do you want to do?'.yellow
  puts '"?" or "help" for a list of available commands'.cyan
  puts
  action = gets.chomp

  case action
  when '?'
    puts ViewUtils.render_help
  when 'add'
    puts "RENDER ADD USER VIEW"
  when 'list'
    users = [
      { 'id' => 124, 'full_name' => 'Erin Swenson-Healey', 'phone_number' => '2061231234', 'email' => 'derp@example.com' },
      { 'id' => 124, 'full_name' => 'Erin Swenson-Healey', 'phone_number' => '2061231234', 'email' => 'derp@example.com' },
      { 'id' => 124, 'full_name' => 'Erin Swenson-Healey', 'phone_number' => '2061231234', 'email' => 'derp@example.com' }
    ]

    puts ViewUtils.render_users users
  when 'quit', 'exit'
    session_over = true
  end
end
