Pod::Spec.new do |spec|

  spec.name         = "pdfDrawing"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of pdfDrawing."
  spec.homepage     = 'https://www.facebook.com/DsolutionDotCom/'
  spec.license      = 'DSolution'
  spec.author       = { "DSolution Macbook" => "thetong1911.2@gmail.com" }
  spec.source       = { :git => "https://github.com/peerawatso/pdfDrawing.git", :tag => spec.version.to_s}
  spec.ios.deployment_target = '12.2'
  spec.framework = 'UIKit', 'PDFKit'
  spec.default_subspec = 'All'

  spec.subspec 'All' do |ss|
    ss.ios.dependency 'pdfDrawing/pdfDrawing'
  end

  spec.subspec 'pdfDrawing' do |ss|
    ss.source_files = 'pdfDrawing/Drawing/**'
    ss.source_files = 'pdfDrawing/Extension/**'
  end
end
