require 'rack'

hello_world = Proc.new do |env|
  puts env
  case env["REQUEST_PATH"]
  when "/"
    make_hello()
  when "/form"
    make_form()
  when "/list"
    make_table(env)
  when "/shutdown"
    exit!
  else
    make_404()
  end
end

def make_hello()
  [200, {"Content-Type" => "text/plain"}, ["Hello from Rack!"]]
end

def make_form()
  form_in = File.new("form.html","r")
  form_out = []
  form_in.each do |line|
    unless line.include? '#'
      form_out << line
    else
      (1..100).each { |num| form_out << line.gsub(/#/, num.to_s) }
    end
  end
  [200, {"Content-Type" => "text/html"}, form_out]
end

def make_table(env)
  [200, {"Content-Type" => "text/html"}, File.new("list.html","r")]
end

def make_404()
  [404, {"Content-Type" => "text/plain"}, ["Page Not Found."]]
end

Rack::Handler::WEBrick.run hello_world, :Port => 8080
