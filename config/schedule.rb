every 1.day, at: '8:00 am' do
  rake 'email:reminder', environment: 'development'
end