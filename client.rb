session_over = false

# faking out a database, or something
users = [
  { 'id' => 124, 'full_name' => 'Erin Swenson-Healey', 'phone_number' => '2061231234', 'email' => 'derp@example.com' },
  { 'id' => 124, 'full_name' => 'Erin Swenson-Healey', 'phone_number' => '2061231234', 'email' => 'derp@example.com' },
  { 'id' => 124, 'full_name' => 'Erin Swenson-Healey', 'phone_number' => '2061231234', 'email' => 'derp@example.com' }
]

module UserManagement

  DATA_WIDTHS  = [5, 20, 20, 20]
  NEWLINE      = "\n"
  ROW_TEMPLATE = "| %s | %s | %s | %s |"
  DIVIDER      = "+#{"-" * (DATA_WIDTHS.reduce(:+) + ROW_TEMPLATE.size - (DATA_WIDTHS.size * 2) - NEWLINE.size - 1)}+"
  LD_WS_REGEX  = /^( |\t)+/

  module_function

  def see_help
    puts <<-eos.gsub(LD_WS_REGEX, ' ')
    Supported commands:

    list            Show the list of users
    edit [id]       Edit a user
    create          Create a user
    delete [id]     Delete a user
    quit, exit      Exit the program

    eos
  end

  def see_prompt
    puts <<-eos.gsub(LD_WS_REGEX, ' ')
    What do you want to do?
    "?" or "help" for a list of available commands
    eos
  end

  def see_users(users)
    render_user = lambda do |user|
      ROW_TEMPLATE % _as_interpolatable([user['id'], user['full_name'], user['email'], user['phone_number']])
    end

    puts <<-eos.gsub(LD_WS_REGEX, ' ')
    #{DIVIDER}
    #{ROW_TEMPLATE % _as_interpolatable(['id', 'full_name', 'email', 'phone_number'])}
    #{DIVIDER}
    #{users.map(&render_user).join("\n ")}
    #{DIVIDER}

    eos
  end

  def see_enter_prompt(prop_name, default=nil)
    print "Enter #{prop_name}: #{default ? "(#{default}) " : ""}"
  end

  def _as_column_template(width)
    "%-#{width}.#{width}s"
  end

  def _as_interpolatable(data)
    raise unless data.size == DATA_WIDTHS.size

    data.zip(DATA_WIDTHS).map do |(item, width)|
      sprintf(_as_column_template(width), item)
    end
  end

end

#
# Intro
#

puts
puts UserManagement.see_users users

#
# Game Loop
#

until session_over do
  puts UserManagement.see_prompt
  action = gets.chomp

  gimme = Proc.new { |prop_name, existing_user={}|
    UserManagement.see_enter_prompt(prop_name, existing_user[prop_name])
    new_value = gets.chomp
    new_value = new_value.empty? ? existing_user[prop_name] : new_value
  }

  case action
  when '?', 'help'
    puts UserManagement.see_help
  when 'add'
    to_add = {
        "id"           => rand(100),
        "full_name"    => gimme.call('full_name'),
        "email"        => gimme.('email'),
        "phone_number" => gimme.('phone_number')
    }
    users << to_add
    UserManagement.see_users users
  when 'list'
    UserManagement.see_users users
  when /delete \d+/
    user_id = action.match(/delete (\d+)/).captures.first.to_i
    users = users.select { |user| user['id'] != user_id }
    UserManagement.see_users users
  when /edit \d+/
    user_id = action.match(/edit (\d+)/).captures.first.to_i
    existing_user = users.find { |user| user['id'] == user_id }

    users = users.map do |user|
      user['id'] == user_id ? {
        "id"           => user_id,
        "full_name"    => gimme.('full_name', existing_user),
        "email"        => gimme.('email', existing_user),
        "phone_number" => gimme.('phone_number', existing_user)
      } : user
    end

    UserManagement.see_users users
  when 'quit', 'exit'
    session_over = true
  end
end
