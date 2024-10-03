User.all.destroy_all
Role.all.destroy_all

role = Role.create!(name: "admin")

admin = User.create!(email: "admin@hintsly.dev", password: "password", password_confirmation: "password")
admin.roles << role