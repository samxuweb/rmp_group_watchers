# RMP Group Watchers plugin
# Copyright (C) 2015 Kovalevsky Vasil (RMPlus company)
# Developed by Kovalevsky Vasil by order of "vira realtime" http://rlt.ru/

module Rmpgw
  module IssuePatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        alias_method_chain :addable_watcher_users, :rmpgw
        alias_method_chain :watcher_user_ids=, :rmpgw
        alias_method_chain :add_watcher, :rmpgw
	alias_method_chain :remove_watcher, :rmpgw
      end
    end

    module InstanceMethods
      def addable_watcher_users_with_rmpgw
        users = addable_watcher_users_without_rmpgw
        Group.order(:lastname).where(type: 'Group').limit(100).to_a + users
      end

      def watcher_user_ids_with_rmpgw=(user_ids)
        if user_ids.is_a?(Array)
          user_ids = user_ids.uniq
          user_ids = User.joins("LEFT JOIN groups_users on groups_users.user_id = #{User.table_name}.id").active.where("groups_users.group_id in (:user_ids) or #{User.table_name}.id in (:user_ids)", user_ids: user_ids + [0]).uniq.sorted.map(&:id)
        end

        send :watcher_user_ids_without_rmpgw=, user_ids
      end

      def add_watcher_with_rmpgw(user, watching=true)
        if user.is_a?(Group)
          self.watchers << Watcher.new(:user_id => user.id)
        elsif user.is_a?(User)
          add_watcher_without_rmpgw
        end
      end

      def remove_watcher_with_rmpgw(user)
          return nil unless user && (user.is_a?(User) || user.is_a?(Group))
          watchers.where(:user_id => user.id).delete_all
      end

      def watcher_users_in_groups
	users_in_group = []
	Group.where(:id => get_group_ids_and_user_ids).map(&:id).each do |group_id|
	  users_in_group += Group.find(group_id).users
	end
	users_in_group
      end

      def watcher_groups
        Group.where(:id => get_group_ids_and_user_ids)
      end

      def get_group_ids_and_user_ids
        self.watchers.collect{ |g| g.user_id}
      end

    end
  end
end
