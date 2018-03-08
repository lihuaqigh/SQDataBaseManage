#
#  Be sure to run `pod spec lint SQDataBaseManage.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    s.name         = 'SQDataBaseManage'
    s.version      = '0.1.0'
    s.summary      = 'DataBase base of LKDB'
    s.homepage     = 'https://github.com/lihuaqigh/SQDataBaseManage.git'

    s.license      = { :type => 'MIT', :file => 'LICENSE' }

    s.authors      = { 'lihuaqigh' => '13261591518@163.com' }

    s.platform     = :ios, '8.0'

    s.source       = { :git => 'https://github.com/lihuaqigh/SQDataBaseManage.git', :tag => s.version.to_s }
    s.source_files        = 'SQDataBaseManage/**/*.{h,m}'
    s.public_header_files = 'SQDataBaseManage/**/*.{h}'

    s.dependency 'LKDBHelper', '~> 2.4.3'
    s.dependency 'SDWebImage', '~> 3.8.2'
end
