
Pod::Spec.new do |s|
  s.name         = "DDStateMachine"
  s.version      = "1.0.0"

  s.summary      = "Loosely based interpretation of the old and well-known state machine."
  s.homepage     = "https://github.com/DeadDogDeus/DDStateMachine"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = "DDStateMachine"

  s.ios.deployment_target = "10.3"

  s.source       = { :git => "https://github.com/DeadDogDeus/DDStateMachine.git", :tag => "#{s.version}" }

  s.source_files = "DDStateMachine/*.{swift,h}", "DDStateMachine/**/*.{swift}"
  s.module_name = 'DDStateMachine'

  s.dependency 'ReactiveSwift', '~> 3.1'
  s.dependency 'Result', '~> 3.2'
end