package { 'ruby':
  ensure => 'installed',
}
package { 'gem':
  ensure => 'installed',
  require => Package["ruby"]
}
package { 'sinatra':
  ensure => 'installed',
  provider => 'gem',
  require => Package[gem]
} 
