
require 'mbox/config/json_helper'

module MBox
    class Config
        class Feature
            BRANCH_PREFIX = 'feature/'
            attr_accessor :branch_prefix
            def branch_prefix
                if @branch_prefix.nil?
                    # 旧代码采用 mbox 前缀
                    @branch_prefix = 'mbox/'
                end
                @branch_prefix
            end

            def branch_prefix=(prefix)
                @branch_prefix = prefix
                if !@branch_prefix.blank? && !@branch_prefix.end_with?("/")
                    @branch_prefix += "/"
                end
            end

            SUPPORT_FILES = []

            attr_accessor :name
            def name
                free? ? "FreeMode" : @name
            end

            def free?
                @name.blank?
            end

            def branch_name
                return nil if free?
                if branch_prefix.blank?
                    name
                else
                    branch_prefix + name
                end
            end

            attr_accessor :stash_hash
            attr_accessor :repos
            def repos
                @repos ||= []
            end

            include JSONable
            def json_class
                {
                    :repos => Repo
                }
            end

            def min_json_var
                [:name, :branch_prefix, :repos]
            end
        end
    end
end
