# 
# STEP_1: install python
# STEP_2: install pip 
#   STEP_2_1: wget pip file from internet
#   STEP_2_2: install downloaded pip.py 
# STEP_3: pip install openpyxl
#

# STEP_1
package { 'python':
  ensure => 'installed'
}

# STEP_2_1
include ::wget
wget::fetch { 'https://bootstrap.pypa.io/get-pip.py':
  destination => '/tmp/pip.py',
  timeout     => 15,
  require     => Package["python"]
}

# STEP_2_2
exec { 'pip install':
  command     => 'python /tmp/pip.py',
  path        => '/usr/bin',
  require     => Package["python"]
}

# STEP_3
package { 'openpyxl':
  ensure   => 'installed',
  provider => 'pip',
  require  => Exec["pip install"]
}
