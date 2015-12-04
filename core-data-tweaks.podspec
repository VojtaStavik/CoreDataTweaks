Pod::Spec.new do |s|
  s.name = 'CoreDataTweaks'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'CoreData helpers for Swift'
  s.homepage = 'https://github.com/VojtaStavik/CoreDataTweaks'
  s.social_media_url = 'http://twitter.com/VojtaStavik'
  s.authors = { "Vojta Stavik" => "stavik@outlook.com" }
  s.source = { :git => 'https://github.com/VojtaStavik/CoreDataTweaks', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files   = '*.swift'
  s.frameworks = 'Foundation', 'CoreData'
  s.dependency 'SwiftyJSON'
  s.requires_arc = true
end
