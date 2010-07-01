require 'oauth'
require 'json'

module Logworm
  class ForbiddenAccessException < Exception ; end
  class DatabaseException < Exception ; end
  class InvalidQueryException < Exception ; end
  
  class DB
    
    URL_FORMAT    = /logworm:\/\/([^:]+):([^@]+)@([^\/]+)\/([^\/]+)\/([^\/]+)\//
    # URI: logworm://<consumer_key>:<consumer_secret>@db.logworm.com/<access_token>/<access_token_secret>/
    
    attr_reader :host, :consumer_key, :consumer_secret, :token, :token_secret

    def initialize(url)
      match = DB.parse_url(url)
      raise ForbiddenAccessException.new("Incorrect URL Format #{url}") unless match and match.size == 6      
      @consumer_key, @consumer_secret, @host, @token, @token_secret = match[1..5]
      @connection = OAuth::AccessToken.new(OAuth::Consumer.new(@consumer_key, @consumer_secret), @token, @token_secret)
    end
  
    def self.with_tokens(token, token_secret)
      consumer_key    = ENV["#{ENV['APP_ID']}_APPS_KEY"]
      consumer_secret = ENV["#{ENV['APP_ID']}_APPS_SECRET"]
      host            = ENV["#{ENV['APP_ID']}_DB_HOST"]
      DB.new(DB.make_url(host, consumer_key, consumer_secret, token, token_secret))
    end
    
    def self.from_config(app = nil)
      # Try with URL from the environment. This will certainly be the case when running on Heroku, in production.
      return DB.new(ENV['LOGWORM_URL']) if ENV['LOGWORM_URL'] and DB.parse_url(ENV['LOGWORM_URL'])
      
      # If no env. found, try with configuration file, unless app specified
      config = Logworm::Config.instance
      config.read
      unless app
        return DB.new(config.url) if config.file_found? and DB.parse_url(config.url)
      end

      # Try with Heroku configuration otherwise
      cmd = "heroku config --long #{app ? " --app #{app}" : ""}"
      config_vars = %x[#{cmd}] || ""
      m = config_vars.match(Regexp.new("LOGWORM_URL\\s+=>\\s+([^\\n]+)"))
      if m and DB.parse_url(m[1])
        config.save(m[1]) unless (config.file_found? and app) # Do not overwrite if --app is provided
        return DB.new(m[1])
      end
      
      nil
    end
    
    def self.from_config_or_die(app = nil)
      db = self.from_config(app)
      raise "The application is not properly configured. Either use 'heroku addon:add' to add logworm to your app, or save your project's credentials into the .logworm file" unless db
      db
    end

    def self.make_url(host, consumer_key, consumer_secret, token, token_secret)
      "logworm://#{consumer_key}:#{consumer_secret}@#{host}/#{token}/#{token_secret}/"
    end

    def url()
      DB.make_url(@host, @consumer_key, @consumer_secret, @token, @token_secret)
    end
    
    def self.example_url
      self.make_url("db.logworm.com", "Ub5sOstT9w", "GZi0HciTVcoFHEoIZ7", "OzO71hEvWYDmncbf3C", "J7wq4X06MihhZgqDeB")
    end

    
    def tables()
      db_call(:get, "#{host_with_protocol}/") || []
    end
  
    def query(table, cond)
      db_call(:post, "#{host_with_protocol}/queries", {:table => table, :query => cond})
    end
  
    def results(uri)
      res = db_call(:get, uri)
      raise InvalidQueryException.new("#{res['error']}") if res['error']
      res["results"] = JSON.parse(res["results"])
      res
    end
    
    def batch_log(entries)
      db_call(:post, "#{host_with_protocol}/log", {:entries => $lr_queue.to_json})
    end

  private
    def db_call(method, uri, params = {})
      begin
        res = @connection.send(method, uri, params)
      rescue SocketError
        raise DatabaseException
      end
      raise InvalidQueryException.new("#{res.body}")              if res.code.to_i == 400
      raise ForbiddenAccessException                              if res.code.to_i == 403
      raise DatabaseException                                     if res.code.to_i == 404
      raise DatabaseException.new("Server returned: #{res.body}") if res.code.to_i == 500
      begin
        JSON.parse(res.body)
      rescue Exception => e
        raise DatabaseException.new("Database reponse cannot be parsed: #{e}")
      end
    end
    
    def self.parse_url(url)
       url.match(URL_FORMAT)
    end
    
    def host_with_protocol
      "http://#{@host}"
    end
  end

end

