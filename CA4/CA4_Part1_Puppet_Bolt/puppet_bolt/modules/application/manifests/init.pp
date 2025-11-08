# Application module
# Manages Spring Boot application deployment

class application (
  String $repo_url = 'https://github.com/spring-guides/tut-rest.git',
  String $app_dir = '/home/vagrant/app',
  String $db_host = '192.168.56.13',
) {
  
  require common

  # ============================================
  # Install Dependencies
  # ============================================
  
  package { ['openjdk-17-jdk', 'git', 'gradle', 'netcat']:
    ensure => installed,
  }

  # ============================================
  # Git Repository Setup
  # ============================================
  
  # Ensure app directory exists
  file { $app_dir:
    ensure  => directory,
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0755',
    require => Package['git'],
  }

  # Clone or update repository
  exec { 'git_clone_app':
    command => "/usr/bin/git clone ${repo_url} ${app_dir} || (cd ${app_dir} && /usr/bin/git pull)",
    creates => "${app_dir}/.git",
    user    => 'vagrant',
    require => [Package['git'], File[$app_dir]],
  }

  # Fix Git safe directory
  exec { 'git_safe_directory':
    command => "/usr/bin/git config --global --add safe.directory ${app_dir}",
    unless  => "/usr/bin/git config --global --get-all safe.directory | /bin/grep -q ${app_dir}",
    user    => 'vagrant',
    require => Exec['git_clone_app'],
  }

  # ============================================
  # Application Configuration
  # ============================================
  
  $project_path = "${app_dir}/complete"

  # Create resources directory
  file { "${project_path}/src/main/resources":
    ensure  => directory,
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0755',
    require => Exec['git_clone_app'],
  }

  # Configure application.properties
  file { "${project_path}/src/main/resources/application.properties":
    ensure  => file,
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0644',
    content => epp('application/application.properties.epp', {
      'db_host' => $db_host,
    }),
    require => File["${project_path}/src/main/resources"],
  }

  # Change ownership to devuser
  exec { 'chown_app_to_developers':
    command => "/bin/chown -R devuser:developers ${app_dir}",
    unless  => "/usr/bin/stat -c '%U:%G' ${app_dir} | /bin/grep -q 'devuser:developers'",
    require => [Exec['git_clone_app'], User['devuser']],
  }

  # Set proper permissions
  file { $app_dir:
    ensure  => directory,
    owner   => 'devuser',
    group   => 'developers',
    mode    => '0750',
    recurse => true,
    require => Exec['chown_app_to_developers'],
  }

  # ============================================
  # Build Application
  # ============================================
  
  # Make gradlew executable
  file { "${project_path}/gradlew":
    ensure  => file,
    mode    => '0755',
    require => Exec['git_clone_app'],
  }

  # Build with Gradle
  exec { 'gradle_build':
    command     => "${project_path}/gradlew clean build -x test --no-daemon",
    cwd         => $project_path,
    environment => [
      "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64",
      "PATH=/usr/lib/jvm/java-17-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    ],
    user        => 'devuser',
    timeout     => 600,
    creates     => "${project_path}/build/libs",
    require     => [
      Package['gradle'],
      Package['openjdk-17-jdk'],
      File["${project_path}/gradlew"],
      File["${project_path}/src/main/resources/application.properties"],
      Exec['chown_app_to_developers'],
    ],
  }

  # ============================================
  # Database Wait Script
  # ============================================
  
  file { '/home/vagrant/wait-for-db.sh':
    ensure  => file,
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0755',
    content => epp('application/wait-for-db.sh.epp'),
    require => Package['netcat'],
  }

  # ============================================
  # Run Application as Service
  # ============================================
  
  $jar_file = "${project_path}/build/libs/rest-service-complete-0.0.1-SNAPSHOT.jar"

  # Create systemd service
  file { '/etc/systemd/system/springboot.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('application/springboot.service.epp', {
      'project_path' => $project_path,
      'jar_file'     => $jar_file,
      'db_host'      => $db_host,
    }),
    require => Exec['gradle_build'],
    notify  => Exec['systemd_reload_springboot'],
  }

  # Reload systemd
  exec { 'systemd_reload_springboot':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  # Enable and start Spring Boot service
  service { 'springboot':
    ensure  => running,
    enable  => true,
    require => [
      File['/etc/systemd/system/springboot.service'],
      Exec['systemd_reload_springboot'],
    ],
  }

  # Wait for service
  exec { 'wait_for_springboot':
    command => '/bin/sleep 10',
    require => Service['springboot'],
  }

  # Health check
  exec { 'health_check_springboot':
    command => '/usr/bin/curl -f http://localhost:8080/employees || /bin/true',
    tries   => 5,
    try_sleep => 3,
    require => Exec['wait_for_springboot'],
  }
}

