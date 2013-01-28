require 'rack'

hello_world = Proc.new do |env|
  puts env
  case env["REQUEST_PATH"]
  when "/"
    make_hello()
  when "/form"
    make_form(env)
  when "/shutdown"
    exit!
  else
    make_404()
  end
end

def make_hello()
  [200, {"Content-Type" => "text/plain"}, ["Hello from Rack!"]]
end

def make_form(env)
  [200, {"Content-Type" => "text/html"}, File.new("form.html","r")]
end

def make_404()
  [404, {"Content-Type" => "text/plain"}, ["Page Not Found."]]
end

Rack::Handler::WEBrick.run hello_world, :Port => 8080
