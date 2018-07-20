Pod::Spec.new do |s|
s.name = "RLP-ObjC"
s.version = '1.0.3'
s.summary = 'Ethereum RLP in Objective-C'

s.description = <<-DESC
Encodes and decodes nested objects for Ethereum
DESC

s.homepage = 'https://github.com/wjmelements/rlp-objc'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.author = { 'William Morriss' => 'william.morriss@consensys.net' }
s.source = { :git => 'https://github.com/wjmelements/rlp-objc.git', :tag => s.version.to_s }

s.source_files = 'src/*', 'include/*'
s.public_header_files = 'include/*'
s.requires_arc = true
s.framework = 'Foundation'

s.pod_target_xcconfig = {
  'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/RLP-ObjC/include"',
}

end
