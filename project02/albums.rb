require 'rack'

hello_world = Proc.new do |env|
  puts env
  case env["REQUEST_PATH"]
  when "/"
    [200, {"Content-Type" => "text/plain"}, ["Hello from Rack!"]]
  else
    [404, {"Content-Type" => "text/plain"}, ["Page Not Found."]]
  end
end

Rack::Handler::WEBrick.run hello_world, :Port => 8080
