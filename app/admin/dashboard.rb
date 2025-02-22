ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: 'Dashboard' do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      # span class: "blank_slate" do
      #   span I18n.t("active_admin.dashboard_welcome.welcome")
      #   small I18n.t("active_admin.dashboard_welcome.call_to_action")
      # end
    end

    columns do
      column do
        panel 'Worlds' do
          ul do
            World.where(user_id: current_user).map do |world|
              li do
                link_to("#{world.name}#{world == current_user.selected_world ? ' *' : ''}", admin_world_path(world)) + ':' + link_to("Select", select_world_admin_world_path(world), class_name: 'btn btn-default')
              end
            end
          end
        end
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
