# if we want to do things like Rails does we may do this:
require ::File.expand_path('../config/application', __FILE__)

app = BestQuotes::Application.new("from config.ru")

use Rack::ContentType

app.route do
  match "", lambda {|env|[200, {}, ["#{env['PATH_INFO']}"]]}
  match "quotes", "quotes#index"
  match "sub-app",
    proc { [200, {}, ["Hello, sub-app!"]] }

  # default routes
  match ":controller/:id/:action"
  match ":controller/:id",
    :default => { "action" => "show" }
  match ":controller",
    :default => { "action" => "index" }
end

run app
