platform :ios, '9.0'

target 'Octowire' do
  use_frameworks!

  pod 'ReSwift',               '~> 3.0'
  pod 'RxSwift',               '~> 3.0'
  pod 'RxCocoa',               '~> 3.0'
  pod 'ObjectMapper',          '~> 2.2'
  pod 'Alamofire',             '~> 4.3'
  pod 'AlamofireObjectMapper', '~> 4.0'
  pod 'Kingfisher',            '~> 3.0'

  def testing_pods
    pod 'RxBlocking', '~> 3.0'
    pod 'RxTest',     '~> 3.0'
    pod 'Quick'
    pod 'Nimble'
  end

  target 'OctowireTests' do
    inherit! :search_paths
    testing_pods
  end

  target 'OctowireUITests' do
    inherit! :search_paths
    testing_pods
  end

end
