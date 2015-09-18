
module Rulers
  class TestApplication

    def call(env)
      `echo debug > debug.txt`;
      [200, {'Content-Type' => 'text/html'},
        ["Hello from Ruby on Rulers!"]]
    end
  end
 
  class Application

    attr_accessor :status, :header, :body
    attr_writer   :application

    def application
      @application
    end
     
    def initialize!(group=:default) #:nodoc:
      raise "Application has been already initialized." if @initialized
      #run_initializers(group, self)
      #@initialized = true
      self
    end

    
    def initialize(text = "new app says Hello!")
      @status      = 200
      @header      = {'Content-Type' => 'text/html'}
      @body        = [text]
    end
      
    def call(env)
      #[@status, @header, @body]

      if env['PATH_INFO'] == '/favicon.ico'
        return [404, @header, @body]
      end

      rack_app = get_rack_app(env)
      rack_app.call(env)
    end    
  end

  # Base class from Sinatra.
  class Base
    include Rack::Utils
    #include Helpers
    #include Templates

    URI_INSTANCE = URI.const_defined?(:Parser) ? URI::Parser.new : URI

    attr_accessor :app, :env, :request, :response, :params
    attr_reader   :template_cache

    def initialize(app = nil)
      super()
      @app = app
      @template_cache = Tilt::Cache.new
      yield self if block_given?
    end

    # Rack call interface.
    def call(env)
      dup.call!(env)
    end

    def call!(env) # :nodoc:
      @env      = env
      @request  = Request.new(env)
      @response = Response.new
      @params   = indifferent_params(@request.params)
      template_cache.clear if settings.reload_templates
      force_encoding(@params)

      @response['Content-Type'] = nil
      invoke { dispatch! }
      invoke { error_block!(response.status) } unless @env['sinatra.error']

      unless @response['Content-Type']
        if Array === body and body[0].respond_to? :content_type
          content_type body[0].content_type
        else
          content_type :html
        end
      end

      @response.finish
    end

    # Access settings defined with Base.set.
    def self.settings
      self
    end

    # Access settings defined with Base.set.
    def settings
      self.class.settings
    end
  end
end