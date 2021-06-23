
require 'mbox/config/json_helper'

module MBox
    class Config
        include JSONable

        # @!group settings

        def config_path
            config_dir + "config.json"
        end

        def save
            File.open(config_path.to_s, "w") do |f|
                f.write(self.to_json)
            end
        end

        attr_accessor :current_feature_name

        def current_feature_name=(feature_name)
            @current_feature_name = feature_name
            add_feature(feature_name) if !feature_name.nil? && feature_for_name(feature_name).nil?
        end

        attr_reader :current_feature
        def current_feature
            feature_for_name(current_feature_name) || feature_for_name("")
        end

        attr_accessor :features
        def features
            @features ||= { "" => Feature.new }
        end

        def free_feature
            feature_for_name(nil)
        end
        
        def feature_for_name(name)
            features[name || ""] || features[(name || "").downcase]
        end

        def rename_feature(old_name, new_name)
            feature = feature_for_name(old_name)
            return nil if feature.blank?
            feature.name = new_name
            features[new_name.downcase] = feature
            delete_feature(old_name)
            feature
        end

        def add_feature(feature_or_name)
            if feature_or_name.is_a?(String)
                name = feature_or_name
                feature = feature_for_name(name)
                if feature.nil?
                    feature = Feature.new(name)
                    require 'securerandom'
                    feature.created_at = DateTime.now.strftime
                    feature.stash_hash = SecureRandom.hex
                    @features[name.downcase] = feature
                end
                feature
            else
                feature = feature_or_name
                if feature_for_name(feature.name).blank?
                    if feature.stash_hash.blank?
                        require 'securerandom'
                        feature.stash_hash = SecureRandom.hex
                    end
                    @features[feature.name.downcase] = feature
                end
                feature
            end
        end

        def delete_feature(name)
            features.delete(name) || features.delete(name.downcase)
        end

        def json_var
            [:current_feature_name, :features]
        end

        def json_class
            {
                :features => [String, Feature],
            }
        end

    end
end