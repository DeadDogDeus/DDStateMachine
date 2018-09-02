Pod::Spec.new do |s|
  s.name     = 'DDStateMachine'
  s.version  = '1.0.0'
  s.license  = { :type => 'MIT' }
  s.homepage = 'https://github.com/DeadDogDeus/DDStateMachine'
  s.authors  = { 'Bondarenko Alex' => 'bondarenkoaleksandr1990@gmail.com' }
  s.summary  = 'Loosely based interpretation of the old and well-known state machine.'
  s.source   = { :git => 'https://github.com/DeadDogDeus/DDStateMachine.git', :tag => "#{s.version}" }
  s.source_files = 'DDStateMachine/**/*.swift'
  s.requires_arc = true

  s.ios.deployment_target = '10.3'
end