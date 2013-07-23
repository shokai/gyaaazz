helpers do
  def app_root
    "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}"
  end

  def filter_api
    if env['PATH_INFO'] =~ /^\/api[\/$]/
      redirect "#{app_root}#{env['PATH_INFO'].gsub(/api/,'API')}"
    end
  end
end
