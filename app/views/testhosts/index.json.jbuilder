json.array!(@testhosts) do |testhost|
  json.extract! testhost, :name, :ip, :status
  json.url testhost_url(testhost, format: :json)
end
