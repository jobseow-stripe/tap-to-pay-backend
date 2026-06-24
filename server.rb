require 'sinatra'
require 'stripe'
require 'dotenv/load'

$client = Stripe::StripeClient.new(ENV.fetch('STRIPE_SECRET_KEY'))

set :root, File.dirname(__FILE__)
set :public_folder, -> { File.join(root, 'public') }
set :static, true
set :port, 4242
set :bind, '0.0.0.0'
set :protection, false

get '/' do
  redirect '/index.html'
end

def create_location
  $client.v1.terminal.locations.create({
    display_name: 'HQ',
    address: {
      line1: '1272 Valencia Street',
      city: 'San Francisco',
      state: 'CA',
      country: 'US',
      postal_code: '94110',
    }
  })
end



# The ConnectionToken's secret lets you connect to any Stripe Terminal reader
# and take payments with your Stripe account.
# Be sure to authenticate the endpoint for creating connection tokens.
post '/connection_token' do
  content_type 'application/json'

  connection_token = $client.v1.terminal.connection_tokens.create
  {secret: connection_token.secret}.to_json
end




post '/capture_payment_intent' do
  data = JSON.parse(request.body.read)

  intent = $client.v1.payment_intents.capture(data['payment_intent_id'])

  intent.to_json
end

