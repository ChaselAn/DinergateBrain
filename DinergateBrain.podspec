Pod::Spec.new do |s|
    s.name         = 'DinergateBrain'
    s.version      = '0.1.5'
    s.summary      = 'APM'
    s.homepage     = 'https://github.com/ChaselAn/DinergateBrain'
    s.license      = 'MIT'
    s.authors      = {'ChaselAn' => '865770853@qq.com'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'https://github.com/ChaselAn/DinergateBrain.git', :tag => s.version}
    s.source_files = 'Demo/DinergateBrain/*.swift'
    s.requires_arc = true
    s.swift_version = '5.0'
end
