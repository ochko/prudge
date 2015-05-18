User.create(login: 'admin', admin: true,
            email: 'change-me@admin.prudge.com',
            password: 'change-me-later',
            password_confirmation: 'change-me-later')

User.create(login: 'judge', judge: true,
            email: 'change-me@judge.prudge.com',
            password: 'change-me-later',
            password_confirmation: 'change-me-later')

Contest.create(name: 'First contest',
               description: 'Please edit description',
               start: Time.now + 1.day,
               end: Time.now + 2.day)
