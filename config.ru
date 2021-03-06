require './config/boot'

# Browser -> Puma -> Health -> Static -> RequestInspector -> Redis -> Protection -> Timeout -> Sinatra
# Browser <- Puma <- Health <- Static <- RequestInspector <- Redis <- Protection <- Timeout <- Sinatra

use Rack::Health, routes: ['/ping', '/PING'], response: ['PONG']
use Rack::Static, root: 'public', urls: ['/favicon.ico', '/js', '/css', '/images']
use Rack::RequestInspector
use Rack::Session::Redis, redis_server: ENV['REDISCLOUD_URL']
use Rack::Protection
use Rack::Protection::AuthenticityToken
use Rack::Timeout

Rack::Timeout.timeout = 10

run MentorMatch::Application
