module TerminalClient

  DATA_WIDTHS  = [5, 20, 20, 20]
  NEWLINE      = "\n"
  ROW_TEMPLATE = "| %s | %s | %s | %s |"
  DIVIDER      = "+#{"-" * (DATA_WIDTHS.reduce(:+) + ROW_TEMPLATE.size - (DATA_WIDTHS.size * 2) - NEWLINE.size - 1)}+"
  LD_WS_REGEX  = /^( |\t)+/

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
