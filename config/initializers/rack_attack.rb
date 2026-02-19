Rack::Attack.throttle("login attempts per IP", limit: 5, period: 20) do |req|
  req.ip if req.path == "/login" && req.post?
end

Rack::Attack.throttle("password reset per IP", limit: 5, period: 20) do |req|
  req.ip if req.path == "/password_resets" && req.post?
end
