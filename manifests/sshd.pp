package { 'openssh-server':
  ensure => installed,
}
service { 'sshd':
  ensure => running,
  enable => true,
}
