namespace :email do
  desc "Email schedule"
  task reminder: :environment do
    reservations_to_expire = Reservation.where(expires_at: Date.tomorrow.all_day).where(status: 'TAKEN')
    reservations_to_expire.each do |reservation|
      book = reservation.book
      reservation.user.book_return_remind(book).deliver
    end
  end
end