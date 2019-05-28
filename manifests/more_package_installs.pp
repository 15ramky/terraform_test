$enhancers = ['strace', 'sudo', 'vim', 'ansible']
package { $enhancers: 
  ensure => 'installed'
}
