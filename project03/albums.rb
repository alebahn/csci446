require 'rack'
require 'erb'
require 'sqlite3'

hello_world = Proc.new do |env|
  request = Rack::Request.new(env)
  case request.path
  when "/"
    make_hello
  when "/form"
    make_form
  when "/list"
    make_table(request)
  when "/style.css"
    get_css
  else
    make_404
  end
end

def make_hello()
  [200, {"Content-Type" => "text/plain"}, ["Hello from Rack!"]]
end

def make_form()
  puts binding
  form_out = [ERB.new(File.read("form.erb"), nil, '%').result(binding)]
  [200, {"Content-Type" => "text/html"}, form_out]
end

def make_table(request)
  sort_by = request["sort_by"].to_i-1
  sort_name = ["rank", "title", "year"][sort_by]
  highlight = request["highlight"].to_i
  list = get_sorted_list sort_name
  list_out = [ERB.new(File.read("list.erb"), nil, '%').result(binding)]
  [200, {"Content-Type" => "text/html"}, list_out]
end

def get_css()
  [200, {"Content-Type" => "text/css"}, File.new("style.css","r")]
end

def make_404()
  [404, {"Content-Type" => "text/plain"}, ["Page Not Found."]]
end

def get_sorted_list(sort_name)
  db = SQLite3::Database.new("albums.sqlite3.db");
  db.execute("SELECT rank, title, year FROM albums ORDER by #{sort_name}");
end

Rack::Handler::WEBrick.run hello_world, :Port => 8080
