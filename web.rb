require 'sinatra'
require 'scrolls'
require 'securerandom'
require 'json'

get '/*' do
  content_type :json
  id = SecureRandom.uuid()
  output = {"id"=>id, "params"=>params}
  Scrolls.log(output)
  output.to_json
end
