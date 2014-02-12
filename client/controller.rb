module UserManagement

  class SessionController

    def initialize(client)
      @client = client
    end

    def on_begin
      puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
    end

    def on_tick
      puts UserManagement::PromptView.new().render
    end

    def on_help
      puts UserManagement::HelpView.new().render
    end

    def on_add
      @client.UserService.create_user({
        "full_name"    => obtain('full_name'),
        "email"        => obtain('email'),
        "phone_number" => obtain('phone_number')
      })

      puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
    end

    def on_edit(user_id)
      existing_user = @client.UserService.get_user_by_id user_id

      @client.UserService.update_user_by_id(user_id, {
        "full_name"    => obtain('full_name', existing_user),
        "email"        => obtain('email', existing_user),
        "phone_number" => obtain('phone_number', existing_user)
      })

      puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
    end

    def on_list
      puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
    end

    def on_delete(user_id)
      @client.UserService.delete_user_by_id user_id

      puts UserManagement::UsersView.new(@client.UserService.get_all_users).render
    end

  private

    def obtain(prop_name, existing_user={})
      print UserManagement::SimplePromptView.new(prop_name, existing_user[prop_name]).render

      new_value = gets.chomp
      new_value = new_value.empty? ? existing_user[prop_name] : new_value
    end

  end

end
