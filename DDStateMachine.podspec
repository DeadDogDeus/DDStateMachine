Pod::Spec.new do |s|  
  s.name     = 'DDStateMachine'
  s.version  = '1.0.0'
  s.homepage = 'https://github.com/DeadDogDeus/DDStateMachine'
  s.authors  = { 'Bondarenko Alex' => 'bondarenkoaleksandr1990@gmail.com' }
  s.summary  = 'Loosely based interpretation of the old and well-known state machine.'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.platform = :ios
  s.source = { :git => "https://github.com/DeadDogDeus/DDStateMachine.git", :tag => "#{s.version}" }
  s.source_files = 'DDStateMachine/**/*.swift'
  s.ios.deployment_target = '10.3'
  s.ios.vendored_frameworks = 'DDStateMachine.framework'
  s.dependency 'Result', '~> 3.2'
  s.dependency 'ReactiveSwift', '~> 3.1'
end