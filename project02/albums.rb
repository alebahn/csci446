require 'rack'

hello_world = Proc.new do |env|
  case env["REQUEST_PATH"]
  when "/"
    make_hello()
  when "/form"
    make_form()
  when "/list"
    make_table(env)
  when "/style.css"
    get_css()
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
  arguments = parse_query_string(env["QUERY_STRING"])
  sort_by = arguments["sort_by"].to_i-1
  sort_name = ["Rank", "Name", "Year"][sort_by]
  highlight = arguments["highlight"].to_i

  list_file = File.new("top_100_albums.txt","r")
  list = list_file.each_with_index.collect { |line, index| line.chomp.split(", ").unshift(index+1) }

  list.sort! { |a,b| a[sort_by]<=>b[sort_by] }

  list_in = File.new("list.html","r")
  list_out = []
  list_in.each do |line|
    unless line.chomp == "<?ruby?>"
      list_out << line
    else
      line_end = line.match($/)[0]
      list_out << "<p>Sorted by #{sort_name}</p>" << line_end

      list_out << "<table>" << line_end
      list.each do |row|
        list_out << (row[0]==highlight ? '<tr class="highlight">' : "<tr>")
        row.each { |value| list_out << "<td>#{value}</td>" }
        list_out << "</tr>" << line_end
      end
      list_out << "</table>" << line_end

    end
  end
  [200, {"Content-Type" => "text/html"}, list_out]
end

def parse_query_string(string)
  Hash[string.split("&").collect { |element| element.split("=") }]
end

def get_css()
  [200, {"Content-Type" => "text/css"}, File.new("style.css","r")]
end

def make_404()
  [404, {"Content-Type" => "text/plain"}, ["Page Not Found."]]
end

Rack::Handler::WEBrick.run hello_world, :Port => 8080
