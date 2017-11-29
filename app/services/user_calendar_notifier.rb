class UserCalendarNotifier
  def initialize(user)
    @client = Google::APIClient.new
    client.autorization.access_token = user.token
    client.authorization.refresh_token = user.refresh_token
    client.authorization.client_id = Figaro.env.google_client_id
    client.authorization.client_secret = Figaro.env.google_client_secret
    client.authorization.refresh!
    @service = client.discovered_api('calendar', 'v3')
  end

  def perform(reservation)
    find_calendar_by(Figaro.env.default_calendar).tap { |cal|
      unless calendar.nil?
        response = client.execute(api_params(cal, reservation))

        if reservation.taken?
          reservation.update_attributes(
            calendar_event_old: response_body_hash(response)['id']
          )
        end
      end
    }
  end

  private
  attr_accessor :client, :service

  def api_params(cal, reservation)
    {
      api_method: service.events.insert,
      parameters: {
        'calendarId' => cal['id'],
        'sendNotifications' => true,
      },
      body: JSON.dump(event(reservation)),
      headers: {'Content-Type' => 'application/json'}
    }
  end

  def event(reservation)
    {
      summary: "'#{reservation.book.title}' expires",
      location: 'Library',
      start: { dateTime: format_time(reservation.expires_at) },
      end:   { dateTime: format_time(reservation.expires_at) },
      description: "Book '#{reservation.book.title}' (ISBN: #{reservation.book.isbn})<br><a href='#{Figaro.env.app_host}/books/#{reservation.book.id}'>link to book page</a>"
    }
  end

  def format_time(time)
    time.utc.strftime("%Y-%m-%dT%H:%M:%S%z")
  end

  def find_calendar_by(hash)
    calendar_list.find { |entry| entry[hash.keys.first.to_s] == hash.values.first }
  end

  def calendar_list
    response_body_hash(
        client.execute(api_method: service.calendar_list.list)
    )['items']
  end

  def response_body_hash(response)
    JSON.parse(response.body)
  end
end