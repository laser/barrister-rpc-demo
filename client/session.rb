require_relative '../lib/barrister_intra_process_transport'
require_relative './controller'
require_relative './views'

require 'barrister'

module TerminalClient

  class Session

    EDIT_REGEX = /edit (\d+)/
    DEL_REGEX  = /delete (\d+)/

    def initialize(service_container)
      transport     = Barrister::IntraProcessTransport.new service_container
      client        = Barrister::Client.new transport
      @controller   = SessionController.new client
    end

    def begin
      @controller.on_begin

      while true do
        @controller.on_tick

        case action = gets.chomp
        when '?', 'help'
          @controller.on_help
        when 'add'
          @controller.on_add
        when EDIT_REGEX
          @controller.on_edit int_from_action(action, EDIT_REGEX)
        when DEL_REGEX
          @controller.on_delete int_from_action(action, DEL_REGEX)
        when 'list'
          @controller.on_list
        when 'quit', 'exit'
          break
        end
      end
    end

  private

    def int_from_action(action, regex)
      action.match(regex).captures.first.to_i
    end

  end

end
