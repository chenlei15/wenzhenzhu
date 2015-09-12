json.array!(@diaries) do |diary|
  json.extract! diary, :id, :title, :body, :date, :user_id
  json.url diary_url(diary, format: :json)
end
