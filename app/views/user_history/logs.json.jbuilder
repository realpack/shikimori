json.content render(
  partial: 'moderations/user_rate_logs/user_rate_log',
  collection: @collection,
  locals: { hide_user: true },
  formats: :html
)

if @collection.size == @limit
  json.postloader render(
    'blocks/postloader',
    next_url: current_url(page: @page + 1),
    prev_url: @page > 1 ? current_url(page: @page - 1) : nil
  )
end
