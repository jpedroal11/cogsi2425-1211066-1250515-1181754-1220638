# Main deployment plan (Agentless)

plan cogsi_ca4_bolt::deploy(
  TargetSpec $targets = 'vms',
) {
  
  out::message('======================================')
  out::message('Starting CA4 Deployment with Puppet Bolt')
  out::message('======================================')
  out::message('')
  
  # Step 1: Apply common configuration
  out::message('[Step 1/4] Applying common configuration (users, groups, PAM)...')
  run_task('common::setup', $targets)
  out::message('Common configuration applied')
  out::message('')
  
  # Step 2: Configure database VM
  out::message('[Step 2/4] Configuring database VM (H2)...')
  run_task('database::setup', 'db')
  out::message('Database configured')
  out::message('')
  
  # Step 3: Configure application VM
  out::message('[Step 3/4] Configuring application VM (Spring Boot)...')
  run_task('application::setup', 'app', {
    'db_host' => '192.168.56.13'
  })
  out::message('Application configured')
  out::message('')
  
  # Step 4: Run health checks
  out::message('[Step 4/4] Running health checks...')
  run_plan('cogsi_ca4_bolt::healthcheck', targets => $targets)
  out::message('')
  
  out::message('======================================')
  out::message('Deployment completed successfully!')
  out::message('======================================')
  out::message('')
  out::message('Application URL: http://192.168.56.12:8080/employees')
  out::message('H2 Console URL: http://192.168.56.13:8082')
  
  return 'Deployment finished'
}
