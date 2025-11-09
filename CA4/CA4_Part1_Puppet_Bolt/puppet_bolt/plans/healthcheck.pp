# Health check plan

plan cogsi_ca4_bolt::healthcheck(
  TargetSpec $targets = 'vms',
) {
  
  out::message('Running health checks...')
  out::message('')
  
  # Health check for database
  out::message('Checking database VM (H2)...')
  $db_check = run_task('healthcheck::check_db', 'db')
  
  if $db_check.ok() {
    out::message('  Database health check: PASSED')
  } else {
    out::message('  Database health check: FAILED')
  }
  out::message('')
  
  # Health check for application
  out::message('Checking application VM (Spring Boot)...')
  $app_check = run_task('healthcheck::check_app', 'app')
  
  if $app_check.ok() {
    out::message('  Application health check: PASSED')
  } else {
    out::message('  Application health check: FAILED')
  }
  out::message('')
  
  return {
    database => $db_check,
    application => $app_check,
  }
}

