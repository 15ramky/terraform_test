# create user1 and user2

user { 'user1':
  ensure           => 'present',
  password_max_age => 30,
}

user { 'user2':
  ensure           => 'present',
  comment          => 'user1_firstname user2_lastname',
  managehome       => true,
  password         => Sensitive("password"),
  password_max_age => 30,
}
