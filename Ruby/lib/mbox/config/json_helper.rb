
require 'json'

module JSONable
  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods

    def min_json_var
      json_var
    end

    def json_var
      self.instance_variables
    end

    def json_class
      {}
    end

    def to_hash(is_min=false)
      hash = {}
      (is_min ? min_json_var : json_var).each do |key|
        key = key.to_s
        key = key[1..-1] if key.start_with?("@")
        var = self.instance_variable_get "@#{key}".to_sym
        hash[key] = to_hash_object(var, is_min) if var
      end
      hash
    end

    def to_json(arg=nil)
      JSON.pretty_generate to_hash
    end

    def from_json_file!(path)
      from_json!(File.read(path)) if path.exist?
    end

    def from_json!(string)
      hash = JSON.load(string)
      return if hash.nil?
      from_json_hash!(hash)
    end

    def from_json_hash!(hash)
      return if hash.empty?
      mapping = self.json_class
      hash.each do |var, val|
        klass = mapping[var.to_sym]
        value = if klass
          if val.is_a? Array
            val.map do |a|
              klass.from_json_object(a)
            end
          elsif val.is_a? Hash
            if klass.is_a? Array
              key, klass = klass
              val.map { |key, value| {key => klass.from_json_object(value)} }.reduce(:merge)
            else
              klass.from_json_object(val)
            end
          else
            val
          end
        else
          val
        end
        self.instance_variable_set "@#{var}".to_sym, value
      end
    end

    private

    def to_hash_object(obj, is_min=false)
      if obj.is_a?(Array)
        obj.map { |o| to_hash_object(o, is_min) }
      elsif obj.is_a?(Hash)
        Hash[obj.map { |k, v| [k, to_hash_object(v, is_min) ] }]
      elsif obj.class.ancestors.include? JSONable
        obj.to_hash(is_min)
      else
        obj
      end
    end
  end

  module ClassMethods

    def from_json_file!(path)
      from_json(File.read(path)) if path.exist?
    end

    def from_json(string)
      hash = JSON.load(string)
      return if hash.nil?
      from_json_object(hash)
    end

    def from_json_object json
      if json.is_a? Hash
        obj = self.new
        obj.from_json_hash!(json)
        obj
      elsif json.is_a? Array
        json.map do |a|
          from_json_object(a)
        end
      else
        json
      end
    end
  end
end
