require 'mbox/config/json_helper'

module MBox
  class Config
    class Repo
      attr_accessor :url

      attr_accessor :name
      attr_accessor :owner
      attr_accessor :full_name

      attr_accessor :base_branch
      attr_accessor :base_type # :tag/:commit/:branch
      def base_type
        (@base_type ||= :branch).to_sym
      end

      attr_accessor :last_branch
      attr_accessor :last_type
      def last_type
        (@last_type ||= :branch).to_sym
      end

      def path
        return working_path if working_path.exist?
        if @path != nil
          @path = Pathname.new(@path)
          return @path if @path.exist?
        end
        nil
      end

      def exist?
        path.exist?
      end

      def initialize(url=nil, base_branch=nil)
        self.url = url unless url.blank?
        @base_branch = base_branch
      end

      def resolve_url
        return if url.nil? || !@name.blank?
        if url =~ /(:|\/)([^\/]+)\/([^\/]+?)((\.git)|$)/
          @owner = $2
          @name = $3
          @full_name = "#{@name}@#{@owner}"
        else
          @name = url.split("/").last
          @full_name = @name
        end
      end

      def dup
        repo = self.class.new
        repo.url = url
        repo.full_name = full_name
        repo.name = name
        repo.owner = owner
        repo.base_branch = base_branch
        repo.base_type = base_type
        repo.last_branch = last_branch
        repo.last_type = last_type
        repo
      end

      def ==(other)
        full_name == other.full_name
      end

      def url=(url)
        @url = url
        resolve_url
      end

      def full_name=(full_name)
        @full_name = full_name
        if @full_name =~ /(.+)@(.+)/
          @name = $1
          @owner = $2
        else
          @name = @full_name
          @owner = nil
        end
      end

      def full_name
        @full_name ||= begin
          @owner.blank? ? @name : "#{@name}@#{@owner}"
        end
      end

      def id_name
        if @full_name =~ /(.+)@(.+)/
          return "#{$2}/#{$1}"
        end
        @full_name
      end

      include JSONable
      def json_var
        [:name, :owner, :url, :base_branch, :base_type, :full_name, :last_branch, :last_type, :path]
      end

      def min_json_var
        [:url, :base_branch, :base_type]
      end

      def from_json_hash!(hash)
        super(hash)
        resolve_url
      end
      ################ Caching ################
      def store_dir
          Config.instance.config_dir + "repos"
      end

      def cache_path
        @cache_path ||= self.store_dir + full_name
      end

      def cache?
        return false if cache_path.symlink?
        cache_path.exist?
      end
      ################ Working ################

      def working_path
        @working_path ||= MBox::Config.instance.installation_root + name
      end

      def working?
        working_path.exist?
      end

      ################ Settings ################

      def settings
        @settings ||= begin
          setting_path = working_path + '.mboxconfig'
          if setting_path.exist?
            JSON.load(File.read(setting_path.to_s))
          else
            {}
          end
        end
      end

      def setting_for_key(key)
        return nil if settings.nil?
        settings[key]
      end
    end
  end
end
