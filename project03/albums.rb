require 'rack'
require 'erb'

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
  form_out = [ERB.new(File.read("form.erb")).result(binding)]
  [200, {"Content-Type" => "text/html"}, form_out]
end

def make_table(request)
  sort_by = request["sort_by"].to_i-1
  sort_name = ["Rank", "Name", "Year"][sort_by]
  highlight = request["highlight"].to_i
  list = get_sorted_list sort_by
  list_out = [ERB.new(File.read("list.erb"), nil, '%').result(binding)]
  [200, {"Content-Type" => "text/html"}, list_out]
end

def get_css()
  [200, {"Content-Type" => "text/css"}, File.new("style.css","r")]
end

def make_404()
  [404, {"Content-Type" => "text/plain"}, ["Page Not Found."]]
end

def get_sorted_list(sort_by)
  list_file = File.new("top_100_albums.txt","r")
  list = list_file.each_with_index.collect { |line, index| line.chomp.split(", ").unshift(index+1) }
  list.sort { |a,b| a[sort_by]<=>b[sort_by] }
end

Rack::Handler::WEBrick.run hello_world, :Port => 8080
