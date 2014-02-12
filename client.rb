require_relative './lib/barrister_intra_process_container'
require_relative './lib/barrister_intra_process_transport'
require_relative './user_service'

require 'barrister'
require 'pry'

module UserManagement

  DATA_WIDTHS  = [5, 20, 20, 20]
  NEWLINE      = "\n"
  ROW_TEMPLATE = "| %s | %s | %s | %s |"
  DIVIDER      = "+#{"-" * (DATA_WIDTHS.reduce(:+) + ROW_TEMPLATE.size - (DATA_WIDTHS.size * 2) - NEWLINE.size - 1)}+"
  LD_WS_REGEX  = /^( |\t)+/

  module_function

  class HelpView

    def render
      <<-eos.gsub(LD_WS_REGEX, '')
      Supported commands:

      list            Show the list of users
      edit [id]       Edit a user
      create          Create a user
      delete [id]     Delete a user
      quit, exit      Exit the program

      eos
    end

  end

  class PromptView

    def render
      <<-eos.gsub(LD_WS_REGEX, '')
      What do you want to do?
      "?" or "help" for a list of available commands

      eos
    end

  end

  class UsersView

    def initialize(users)
      @users = users
    end

    def render
      render_user = lambda do |user|
        ROW_TEMPLATE % as_interpolatable([user['id'], user['full_name'], user['email'], user['phone_number']])
      end

      puts <<-eos.gsub(LD_WS_REGEX, '')
      #{DIVIDER}
      #{ROW_TEMPLATE % as_interpolatable(['id', 'full_name', 'email', 'phone_number'])}
      #{DIVIDER}
      #{@users.map(&render_user).join("\n")}
      #{DIVIDER}
      eos
    end

  private

    def as_interpolatable(data)
      raise unless data.size == DATA_WIDTHS.size

      data.zip(DATA_WIDTHS).map do |(item, width)|
        sprintf(as_column_template(width), item)
      end
    end

    def as_column_template(width)
      "%-#{width}.#{width}s"
    end

  end

  class SimplePromptView

    def initialize(prop_name, default=nil)
      @prop_name = prop_name
      @default = default
    end

    def render
      "Enter #{@prop_name}: #{@default ? "(#{@default}) " : ""}"
    end

  end

end

module UserManagement

  class Session

    EDIT_REGEX = /edit (\d+)/
    DEL_REGEX  = /delete (\d+)/

    def initialize
      container     = Barrister::IntraProcessContainer.new './user_service.json', UserService
      transport     = Barrister::IntraProcessTransport.new container
      @client       = Barrister::Client.new transport
      @session_over = false
    end

    def begin
      puts
      puts UserManagement::UsersView.new(@client.UserService.get_all_users).render

      until @session_over do
        puts UserManagement::PromptView.new().render
        action = gets.chomp
        puts

        gimme = Proc.new { |prop_name, existing_user={}|
          print UserManagement::SimplePromptView.new(prop_name, existing_user[prop_name]).render
          new_value = gets.chomp
          new_value = new_value.empty? ? existing_user[prop_name] : new_value
        }

        case action
        when '?', 'help'
          puts UserManagement::HelpView.new().render
        when 'add'
          @client.UserService.create_user({
            "full_name"    => gimme.('full_name'),
            "email"        => gimme.('email'),
            "phone_number" => gimme.('phone_number')
          })
          puts
          puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
        when EDIT_REGEX
          user_id       = int_from_action action, EDIT_REGEX
          existing_user = @client.UserService.get_user_by_id user_id

          @client.UserService.update_user_by_id(user_id, {
            "full_name"    => gimme.('full_name', existing_user),
            "email"        => gimme.('email', existing_user),
            "phone_number" => gimme.('phone_number', existing_user)
          })
          puts
          puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
        when 'list'
          puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
        when DEL_REGEX
          @client.UserService.delete_user_by_id int_from_action(action, DEL_REGEX)
          puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
        when 'quit', 'exit'
          @session_over = true
        end
      end

    end

  private

    def int_from_action(action, regex)
      action.match(regex).captures.first.to_i
    end

  end

end

session = UserManagement::Session.new
session.begin
