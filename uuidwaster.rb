require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'simple_uuid'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/stats.db")

class Stat
  include DataMapper::Resource
  property :id,         Serial
  property :count,      Integer
  property :created_at, DateTime
end

configure :development do
  DataMapper.auto_upgrade!
end

before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
end

helpers do
  
  # Borrowed from ActiveSupport
  def number_with_delimiter(number)
    begin
      parts = number.to_s.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      parts.join
    rescue
      number
    end
  end
end

get '/' do
  Stat.create(:id => 1, :count => 0) if Stat.first.nil?
  erb :index
end

post '/' do
  stat = Stat.first
  begin
    stat.count = stat.count + 1
    stat.save
  rescue
    nil
  end
  "#{UUID.new.to_guid}:Wasted #{number_with_delimiter(stat.count)} UUIDs since #{stat.created_at.strftime('%d %B %Y')}"
end

__END__

@@ index
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>UUID Waster</title>
    <link href="/styles.css" rel="stylesheet" type="text/css">
  </head>
  <body>
    <div>
      <p id="uuid">loading</p>
      <p id="explanation">
        A Universally Unique Identifier (UUID) is a 128-bit number defined by <a href="http://tools.ietf.org/html/rfc4122">RFC 4122</a> that is for all intents and purposes guaranteed to be unique.
        For example, the probability of a duplicate UUID would be about 50% if every person on earth&mdash;population approaching seven billion people&mdash;owned 600 million UUIDs.
      </p>
      <p id="count"></p>
      <p id="about">&copy;2010 <a href="http://johntopley.com/">John Topley</a> (<a href="http://github.com/johntopley/uuidwaster">Source</a>)</p>
    </div>
    <script src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("jquery", "1.4.2");
      function go() {
        var uuid = $("#uuid");
        $.post("/", function(data) {
          var pos = data.search(/:/)
          uuid.html(data.substr(0, pos));
          $("#count").html(data.substr(pos + 1) + ".")
        });
        setTimeout("go();", 1000);
      }
      google.setOnLoadCallback(function() {
        go();
      });
    </script>
  </body>
</html>