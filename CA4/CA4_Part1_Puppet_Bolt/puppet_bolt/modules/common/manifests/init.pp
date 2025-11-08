# Common module
# Manages users, groups, and PAM password policy configuration

class common {
  
  # ============================================
  # User and Group Management
  # ============================================
  
  group { 'developers':
    ensure => present,
    gid    => 3000,
  }

  user { 'devuser':
    ensure     => present,
    uid        => 3000,
    gid        => 'developers',
    groups     => ['developers'],
    managehome => true,
    shell      => '/bin/bash',
    home       => '/home/devuser',
    require    => Group['developers'],
  }

  # ============================================
  # PAM Password Policy Configuration
  # ============================================
  
  # Install required packages
  package { 'libpam-pwquality':
    ensure => installed,
  }

  package { 'libpam-modules':
    ensure => installed,
  }

  # Configure pwquality (password complexity)
  file { '/etc/security/pwquality.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('common/pwquality.conf.epp'),
    require => Package['libpam-pwquality'],
  }

  # Configure faillock (account lockout)
  file { '/etc/security/faillock.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('common/faillock.conf.epp'),
    require => Package['libpam-modules'],
  }

  # Configure common-password for password history
  file_line { 'pam_password_history':
    ensure  => present,
    path    => '/etc/pam.d/common-password',
    line    => 'password [success=1 default=ignore] pam_unix.so obscure use_authtok try_first_pass yescrypt remember=5',
    match   => '^password.*pam_unix.so',
    require => Package['libpam-modules'],
  }

  # Configure common-auth for faillock
  file_line { 'pam_faillock_preauth':
    ensure  => present,
    path    => '/etc/pam.d/common-auth',
    line    => 'auth required pam_faillock.so preauth',
    after   => '^auth.*pam_env.so',
    require => File['/etc/security/faillock.conf'],
  }

  file_line { 'pam_faillock_authfail':
    ensure  => present,
    path    => '/etc/pam.d/common-auth',
    line    => 'auth [default=die] pam_faillock.so authfail',
    after   => '^auth.*pam_unix.so',
    require => File['/etc/security/faillock.conf'],
  }

  file_line { 'pam_faillock_authsucc':
    ensure  => present,
    path    => '/etc/pam.d/common-auth',
    line    => 'auth sufficient pam_faillock.so authsucc',
    after   => '^auth.*\[default=die\].*pam_faillock.so authfail',
    require => File['/etc/security/faillock.conf'],
  }
}

