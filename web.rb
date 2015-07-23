require 'webrick'
require 'securerandom'

$stdout.sync = true

server = WEBrick::HTTPServer.new Port: ENV.fetch("PORT", "4567")
server.mount_proc "/" do |req, res|
  id = SecureRandom.uuid
  puts "id=#{id}"
  res.body = "id=#{id}"
end

trap("INT"){ server.stop }
server.start
