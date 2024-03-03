# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examplex:
#
#  #  movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#  #  Character.create(name: "Luke", movie: movies.first)
# ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#    MovieGenre.find_or_create_by!(name: genre_name)
#  end
User.create(
  email: 'tayloredwebsites@me.com',
  full_name: 'Dave Taylor',
  password: 'password',
  password_confirmation: 'password',
  confirmed_at: Time.now.utc,
)
