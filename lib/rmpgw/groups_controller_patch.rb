# RMP Group Watchers plugin
# Developed by Sam

module Rmpgw
  module GroupsControllerPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        alias_method_chain :add_users, :rmpgw
        alias_method_chain :remove_user, :rmpgw
      end
    end

    module InstanceMethods
     def add_users_with_rmpgw
       Watcher.where(:user_id => @group.id).map(&:watchable_id).each do |issue_id|
	 if params[:user_id]
	   Issue.find(issue_id).watchers << Watcher.new(:user_id => params[:user_id])
	elsif params[:user_ids]
	  params[:user_ids].each do |user_id|
	   Issue.find(issue_id).watchers << Watcher.new(:user_id => user_id)
 	  end
	end
       end
       add_users_without_rmpgw
     end

    def remove_user_with_rmpgw
      Watcher.where(:user_id => @group.id).map(&:watchable_id).each do |issue_id|
        Issue.find(issue_id).set_watcher(User.find(params[:user_id]), false)
      end
      remove_user_without_rmpgw
    end

    end
  end
end
