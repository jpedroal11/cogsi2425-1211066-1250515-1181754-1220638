# Database module
# Manages H2 Database installation and configuration

class database {
  
  require common

  # ============================================
  # Install Dependencies
  # ============================================
  
  package { ['openjdk-17-jdk', 'wget', 'curl', 'netcat']:
    ensure => installed,
  }

  # ============================================
  # H2 Database Setup
  # ============================================
  
  # Create H2 directory
  file { '/opt/h2':
    ensure  => directory,
    owner   => 'devuser',
    group   => 'developers',
    mode    => '0750',
    require => [User['devuser'], Package['openjdk-17-jdk']],
  }

  # Download H2 JAR
  exec { 'download_h2':
    command => '/usr/bin/wget https://repo1.maven.org/maven2/com/h2database/h2/2.4.240/h2-2.4.240.jar -O /opt/h2/h2.jar',
    creates => '/opt/h2/h2.jar',
    timeout => 300,
    require => [File['/opt/h2'], Package['wget']],
  }

  # Set permissions on H2 JAR
  file { '/opt/h2/h2.jar':
    ensure  => file,
    owner   => 'devuser',
    group   => 'developers',
    mode    => '0755',
    require => Exec['download_h2'],
  }

  # Create database directory
  file { '/home/vagrant/mydb':
    ensure  => directory,
    owner   => 'devuser',
    group   => 'developers',
    mode    => '0750',
    require => User['devuser'],
  }

  # Create H2 systemd service
  file { '/etc/systemd/system/h2.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(END),
      [Unit]
      Description=H2 Database Server
      After=network.target

      [Service]
      Type=simple
      User=devuser
      Group=developers
      WorkingDirectory=/opt/h2
      ExecStart=/usr/bin/java -cp /opt/h2/h2.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -web -webAllowOthers -webPort 8082 -ifNotExists
      Restart=on-failure
      RestartSec=10

      [Install]
      WantedBy=multi-user.target
      | END
    require => [File['/opt/h2/h2.jar'], User['devuser']],
    notify  => Exec['systemd_reload_h2'],
  }

  # Reload systemd
  exec { 'systemd_reload_h2':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  # Enable and start H2 service
  service { 'h2':
    ensure  => running,
    enable  => true,
    require => [File['/etc/systemd/system/h2.service'], Exec['systemd_reload_h2']],
  }

  # Wait for service to be ready
  exec { 'wait_for_h2':
    command => '/bin/sleep 5',
    require => Service['h2'],
  }

  # Check if H2 TCP port is listening
  exec { 'health_check_h2_port':
    command => '/bin/ss -tln | /bin/grep :9092',
    tries   => 5,
    try_sleep => 2,
    require => Exec['wait_for_h2'],
  }
}

