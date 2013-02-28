module ParseResource
  #
  # ParseResource::Base provides an easy way to use Ruby to interace
  # with a Parse.com backend
  #
  # Example Usage
  #
  #   class User < ParseUser
  #     has_many :comments
  #   end
  #
  #   class Comment < ParseResource::Base
  #     belongs_to :user
  #     belongs_to :thread
  #     fields :body
  #   end
  #
  #   class Thread < ParseResource::Base
  #     has_many :comments
  #     fields :title
  #   end
  #
  class Base
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveModel::Conversion
    include ActiveModel::AttributeMethods
    include ParseResource::QueryMethods

    extend ActiveModel::Naming
    extend ActiveModel::Callbacks

    define_model_callbacks :save, :create, :update, :destroy

    #
    # Instantiates a ParseResource::Base object
    #
    # @params [Hash], [Boolean] a `Hash` of attributes and a `Boolean`
    #         that should be false only if the object already exists
    # @return [ParseResource::Base] an object that subclasses
    #         `Parseresource::Base`
    #
    def initialize(new_attributes={}, new=true)
      self.class.fields(*new_attributes.keys)

      self.attributes = new_attributes
      attributes.mark_as_clean! unless new
    end

    def to_pointer
      klass_name = self.class.model_name
      klass_name = "_User" if klass_name == "User"
      klass_name = "_Installation" if klass_name == "Installation"
      {"__type" => "Pointer", "className" => klass_name, "objectId" => id}
    end

    def persisted?
      id.present?
    end

    def new?
      !persisted?
    end

    # delegate from Class method
    def resource
      self.class.resource
    end

    # create RESTful resource for the specific Parse object
    # sends requests to [base_uri]/[classname]/[objectId]
    def instance_resource
      self.class.resource[id]
    end

    def save(options={})
      if perform_save?(options)
        create_or_update
      end
    end

    def save!(options={})
      if perform_save?(options)
        create_or_update || raise(RecordNotSaved)
      else
        raise(RecordInvalid.new(self))
      end
    end

    def update_attributes(new_attributes = {})
      self.attributes = new_attributes
      save
    end

    def update_attributes!(new_attributes = {})
      update_attributes(new_attributes) || raise(RecordNotSaved)
    end

    def destroy
      run_callbacks :destroy do
        if self.instance_resource.delete
          @data_provider = nil
          return true
        end
        false
      end
    end

    def reload
      return false if new?

      @data_provider = nil
      fresh_object = self.class.find(id)
      self.attributes = fresh_object.attributes
      attributes.mark_as_clean!
      self
    end

    def attributes=(attributes)
      attributes.each do |k, v|
        if respond_to? "#{k}="
          send "#{k}=", v
        else
          raise(UnknownAttributeError, "unknown attribute: #{k}")
        end
      end
      attributes
    end

    def id
      objectId rescue nil
    end

    # Explicitly adds a field to the model.
    #
    # @param [Symbol] name the name of the field, eg `:author`.
    def self.field(field)
      class_eval do
        unless respond_to? field
          define_method(field) do
            attributes[field]
          end
        end

        unless respond_to? "#{field}="
          define_method("#{field}=") do |value|
            attributes[field] = value
            value
          end
        end
      end
    end

    # Add multiple fields in one line. Same as `#field`, but accepts multiple args.
    #
    # @param [Array] *args an array of `Symbol`s, `eg :author, :body, :title`.
    def self.fields(*args)
      args.each {|f| field(f)}
    end

    # Configure built-ins
    fields :objectId, :createdAt, :updatedAt

    #
    # Basic support for simple associations.
    #
    # class Tree
    #   has_one :apple
    # end
    #
    # class Apple
    #   belongs_to :tree
    # end
    #
    # Tree.find(1).apple
    # Apple.find(1).tree
    #
    class << self
      alias_method :belongs_to, :field
    end

    def self.has_one(association)
      class_eval do
        define_method(association) do
          name = self.class.model_name[0].downcase + self.class.model_name[1..-1]
          klass = association.to_s.titleize.constantize
          klass.where name.to_sym => self.to_pointer, :limit => 1
        end
      end
    end

    def self.has_many(association)
      class_eval do
        define_method(association) do
          name = self.class.model_name[0].downcase + self.class.model_name[1..-1]
          klass = association.to_s.singularize.titleize.constantize
          klass.where name.to_sym => self.to_pointer
        end
      end
    end

    def self.to_date_object(date)
      {"__type" => "Date", "iso" => date.iso8601} if date && (date.is_a?(Date) || date.is_a?(DateTime) || date.is_a?(Time))
    end

    def self.find_all_by(field, value)
      if value.respond_to? :to_pointer
        value = value.to_pointer
      end
      where(field.to_sym => value)
    end

    def self.method_missing(method_name, *args)
      if /\Afind_by_(?<attribute_name>\w+)\z/ =~ method_name.to_s
        define_singleton_method(method_name) {|v| find_all_by( attribute_name, v).first }
        send method_name, args.first
      elsif /\Afind_all_by_(?<attribute_name_all>\w+)\z/ =~ method_name.to_s
        define_singleton_method(method_name) {|v| find_all_by(attribute_name_all, v) }
        send method_name, args.first
      else
        super
      end
    end

    # Explicitly set Parse.com API keys.
    #
    # @param [String] app_id the Application ID of your Parse database
    # @param [String] master_key the Master Key of your Parse database
    def self.load!(app_id, master_key)
      ParseSettings.app_id = app_id
      ParseSettings.master_key = master_key
    end

    # Send requests to [base_uri]/[classname]
    def self.resource
      case model_name
      when "User"
        # https://parse.com/docs/rest#users-signup
        base_uri = "https://api.parse.com/1/users"
      when "Installation"
        # https://parse.com/docs/rest#installations
        base_uri = "https://api.parse.com/1/installations"
      else
        base_uri = "https://api.parse.com/1/classes/#{model_name}"
      end
      RestClient::Resource.new(base_uri, ParseSettings.app_id, ParseSettings.master_key)
    end

    # Creates a RESTful resource for file uploads
    # sends requests to [base_uri]/files
    #
    def self.upload(file_instance, filename, options={})
      base_uri = "https://api.parse.com/1/files"

      app_id     = ParseSettings.app_id
      master_key = ParseSettings.master_key

      options[:content_type] ||= 'image/jpg' # TODO: Guess mime type here.
      file_instance = File.new(file_instance, 'rb') if file_instance.is_a? String

      filename = filename.parameterize

      private_resource = RestClient::Resource.new "#{base_uri}/#{filename}", app_id, master_key
      private_resource.post(file_instance, options) do |resp, req, res, &block|
        return false if resp.code == 400
        return JSON.parse(resp) rescue {"code" => 0, "error" => "unknown error"}
      end
      false
    end

    # Find a ParseResource::Base object by ID
    #
    # @param [String] id the ID of the Parse object you want to find.
    # @return [ParseResource] an object that subclasses ParseResource.
    def self.find(id)
      raise RecordNotFound if id.blank?
      where(:objectId => id).first || raise(RecordNotFound)
    end

    # Find a ParseResource::Base object by chaining #where method calls.
    #
    def self.where(*args)
      Query.new(self).where(*args)
    end

    # Create a ParseResource::Base object.
    #
    # @param [Hash] attributes a `Hash` of attributes
    # @return [ParseResource] an object that subclasses `ParseResource`. Or returns `false` if object fails to save.
    def self.create(attributes = {})
      obj = new(attributes)
      obj.save
      obj
    end

    def self.create!(attributes = nil, options = {}, &block)
      if attributes.is_a?(Array)
        attributes.collect { |attr| create!(attr, options, &block) }
      else
        object = new(attributes, options)
        yield(object) if block_given?
        object.save!
        object
      end
    end

    # TODO - Conditions
    def self.destroy_all(*)
      all.map(&:destroy)
    end

    private

      def attributes
        @data_provider ||= DataProvider.new
      end

      def perform_save?(options={})
        options[:validate] == false || valid?
      end

      def create_or_update
        run_callbacks(:save) do
          result = new? ? create : update
          result != false
        end
      end

      def update
        run_callbacks(:update) do
          put_attrs = attributes.unsaved
          put_attrs.delete('objectId')
          put_attrs.delete('createdAt')
          put_attrs.delete('updatedAt')
          put_attrs = put_attrs.to_json

          opts = {:content_type => "application/json"}
          self.instance_resource.put(put_attrs, opts) do |resp, req, res, &block|
            if resp.code == 200 || resp.code == 201
              new_attributes = JSON.parse(resp)
              self.class.fields(*new_attributes.keys)
              self.attributes = new_attributes
              attributes.mark_as_clean!
              return true
            else
              error_response = JSON.parse(resp)
              pe = ParseError.new(resp.code.to_s, error_response).to_array
              self.errors.add(pe[0], pe[1])
              return false
            end
          end
        end
      end

      def create
        run_callbacks(:create) do
          opts = {:content_type => "application/json"}
          attrs = attributes.unsaved.to_json
          self.resource.post(attrs, opts) do |resp, req, res, &block|
            if resp.code == 200 || resp.code == 201
              new_attributes = JSON.parse(resp)
              self.class.fields(*new_atttributes.keys)
              self.attributes = new_attributes
              attributes.mark_as_clean!
              return true
            else
              error_response = JSON.parse(resp)
              pe = ParseError.new(resp.code.to_s, error_response).to_array
              self.errors.add(pe[0], pe[1])
              return false
            end
          end
        end
      end
  end

  #
  # Data provider to manage model attributes
  #
  class DataProvider < ActiveSupport::HashWithIndifferentAccess

    attr_reader :unsaved

    def initialize(*args)
      super
      mark_as_clean!
    end

    def []=(key, value)
      value = transform_for_write(value)
      @unsaved[key] = value
      super
    end

    def [](key)
      transform_for_return super(key)
    end

    def mark_as_clean!
      @unsaved = {}.with_indifferent_access
    end

    private

      def transform_for_write(attribute)
        if attribute.is_a?(Date) || attribute.is_a?(Time) || attribute.is_a?(DateTime)
          attribute = {"__type" => "Date", "iso" => attribute.iso8601}
        elsif attribute.respond_to?(:to_pointer)
          attribute = attribute.to_pointer
        end
        attribute
      end

      def transform_for_return(attribute)
        case attribute
        when Hash
          klass_name = attribute["className"]
          klass_name = "User" if klass_name == "_User"
          klass_name = "Installation" if klass_name == "_Installation"
          case attribute["__type"]
          when "Pointer"
            result = klass_name.constantize.find(attribute["objectId"])
          when "Object"
            result = klass_name.constantize.new(attribute, false)
          when "Date"
            result = DateTime.parse(attribute["iso"])
          when "GeoPoint"
            result = ParseGeoPoint.new(attribute)
          end #todo: support other types https://www.parse.com/docs/rest#objects-types
        else
          result = attribute
        end
        result
      end
  end

end
