#!/usr/bin/ruby

require 'mbox/config/config.rb'
require 'mbox/config/repo.rb'
require 'mbox/config/feature.rb'
require 'active_support'
if ActiveSupport.version >= Gem::Version.new("6.0")
  require 'active_support/multibyte/unicode'
end

module MBox
  class Config
    DEFAULTS = {
      :verbose             => false,
      :silent              => false,
      :base_branch         => "develop"
    }

    # Applies the given changes to the config for the duration of the given
    # block.
    #
    # @param [Hash<#to_sym,Object>] changes
    #        the changes to merge temporarily with the current config
    #
    # @yield [] is called while the changes are applied
    #
    def with_changes(changes)
      old = {}
      changes.keys.each do |key|
        key = key.to_sym
        old[key] = send(key) if respond_to?(key)
      end
      configure_with(changes)
      yield if block_given?
    ensure
      configure_with(old)
    end

    public

    #-------------------------------------------------------------------------#

    # @!group UI

    # @return [Bool] Whether CocoaPods should provide detailed output about the
    #         performed actions.
    #
    attr_accessor :verbose
    alias_method :verbose?, :verbose

    # @return [Bool] Whether CocoaPods should produce not output.
    #
    attr_accessor :silent
    alias_method :silent?, :silent

    # @return [Bool] Whether CocoaPods should redirect the log to STDERR and keep the `puts_api`.
    #
    attr_accessor :api
    alias_method :api?, :api

    # @return [Bool] Whether a message should be printed when a new version of
    #         CocoaPods is available.
    #
    attr_accessor :new_version_message
    alias_method :new_version_message?, :new_version_message

    #-------------------------------------------------------------------------#

    # @!group Installation

    # @return [Bool] Whether the installer should skip the download cache.
    #
    attr_accessor :skip_download_cache
    alias_method :skip_download_cache?, :skip_download_cache

    public

    #-------------------------------------------------------------------------#

    # @!group Cache

    # @return [Pathname] The directory where CocoaPods should cache remote data
    #         and other expensive to compute information.
    #
    attr_accessor :cache_root

    def cache_root
      @cache_root.mkpath unless @cache_root.exist?
      @cache_root
    end

    public

    #-------------------------------------------------------------------------#

    # @!group Initialization

    def initialize(use_user_settings = true)
      configure_with(DEFAULTS)
    end

    def verbose
      @verbose && !silent
    end

    private

    def normalize(path)
      if ActiveSupport.version >= Gem::Version.new("6.0")
        path.unicode_normalize(:nfkc)
      else
        ActiveSupport::Multibyte::Unicode.normalize(path)
      end
    end

    public

    #-------------------------------------------------------------------------#

    # @!group Paths

    # @return [Pathname] the root of the CocoaPods installation where the
    #         Podfile is located.
    #
    def installation_root
      unless @installation_root
        unless ENV["MBOX_ROOT"].blank?
          current_dir = normalize(ENV["MBOX_ROOT"])
          current_path = Pathname.new(current_dir)
          set_installation_root(current_path)
        end
        unless @installation_root
          current_dir = normalize(Dir.pwd)
          current_path = Pathname.new(current_dir)
          until current_path.root?
            break if set_installation_root(current_path)
            current_path = current_path.parent
          end
        end
        @installation_root ||= Pathname.pwd
      end
      @installation_root

    end

    attr_writer :installation_root
    alias_method :project_root, :installation_root

    def config_dir
      installation_root + ".mbox"
    end

    # Sets the values of the attributes with the given hash.
    #
    # @param  [Hash{String,Symbol => Object}] values_by_key
    #         The values of the attributes grouped by key.
    #
    # @return [void]
    #
    def configure_with(values_by_key)
      return unless values_by_key
      values_by_key.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Returns the path of the Podfile in the given dir if any exists.
    #
    # @param  [Pathname] dir
    #         The directory where to look for the Podfile.
    #
    # @return [Pathname] The path of the Podfile.
    # @return [Nil] If not Podfile was found in the given dir
    #
    def mbox_path_in_dir(dir)
      candidate = dir + ".mbox"
      if candidate.exist?
        return candidate
      end
      nil
    end

    def set_installation_root(dir)
      if mbox_path_in_dir(dir)
        @installation_root = dir
        true
      else
        false
      end
    end

    attr_accessor :loaded_json

    public

    #-------------------------------------------------------------------------#

    # @!group Singleton

    # @return [Config] the current config instance creating one if needed.
    #
    def self.instance
      @instance ||= new
      unless @instance.loaded_json
        @instance.loaded_json = true
        @instance.from_json_file!(@instance.config_path)
      end
      @instance
    end

    # Sets the current config instance. If set to nil the config will be
    # recreated when needed.
    #
    # @param  [Config, Nil] the instance.
    #
    # @return [void]
    #
    class << self
      attr_writer :instance
    end

    # Provides support for accessing the configuration instance in other
    # scopes.
    #
    module Mixin
      def config
        Config.instance
      end
    end
  end
end
