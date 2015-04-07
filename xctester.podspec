Pod::Spec.new do |s|
  s.name         = "xctester"
  s.version      = "0.1.5"
  s.summary      = "Run, XCTest, run"
  s.homepage     = "https://github.com/neonichu/xctester"
  s.license      = "MIT"

  s.author             = { "Boris Bügling" => "boris@buegling.com" }
  s.social_media_url   = "http://twitter.com/NeoNacho"

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.requires_arc          = true

  s.source       = { :git => "https://github.com/neonichu/xctester.git",
                     :tag => s.version }
  s.source_files = "code/XCTestCaseExtensions.swift"
  s.framework    = "XCTest"
end
