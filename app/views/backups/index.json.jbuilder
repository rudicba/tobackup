json.array!(@backups) do |backup|
  json.extract! backup, :path, :status, :last, :user_id, :host_id
  json.url backup_url(backup, format: :json)
end
