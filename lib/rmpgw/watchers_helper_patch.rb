# RMP Group Watchers plugin
# Developed by Sam Xu

module Rmpgw
  module WatchersHelperPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        alias_method_chain :watchers_list, :rmpgw
      end
    end

    module InstanceMethods
      # Returns a comma separated list of users and groups watching the given object
      def watchers_list_with_rmpgw(object)
        remove_allowed = User.current.allowed_to?("delete_#{object.class.name.underscore}_watchers".to_sym, object.project)
        content = ''.html_safe
        lis = (object.watcher_users + object.watcher_groups).collect do |user|
          s = ''.html_safe
          s << avatar(user, :size => "16").to_s
          s << link_to_user(user, :class => 'user')
          if remove_allowed && !object.watcher_users_in_groups.include?(user)
            url = {:controller => 'watchers',
                   :action => 'destroy',
                   :object_type => object.class.to_s.underscore,
                   :object_id => object.id,
                   :user_id => user,
		   :type => user.type}
            s << ' '
            s << link_to(image_tag('delete.png'), url,
                         :remote => true, :method => 'delete', :class => "delete")
          end
          content << content_tag('li', s, :class => "user-#{user.id}")
        end
        content.present? ? content_tag('ul', content, :class => 'watchers') : content
      end

    end
  end
end
