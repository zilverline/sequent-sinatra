class AppForTest < Sinatra::Base

  register Sequent::Web::Sinatra::App
  set :show_exceptions, false

  error do
    puts "#{env['sinatra.error'].class} #{env['sinatra.error'].to_s}"
    puts "#{env['sinatra.error'].backtrace.join("\n")}"
    status 500
  end

  get '/' do
    "OK"
  end
end

