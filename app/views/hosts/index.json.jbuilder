json.array!(@hosts) do |host|
  json.extract! host, :name, :ip, :status
  json.url host_url(host, format: :json)
end
