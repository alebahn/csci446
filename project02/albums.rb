require 'rack'

hello_world = Proc.new do |env|
  [200, {"Content-Type" => "text/plain"}, ["Hello from Rack!"]]
end

Rack::Handler::WEBrick.run hello_world, :Port => 8080
