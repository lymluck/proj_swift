source "git@code.smartstudy.com:chenyusen/SSSpecs.git"
#source "https://gitee.com/MrErGe/PFVideoPlayerSpecs.git"
source "https://github.com/CocoaPods/Specs"

platform :ios,'9.0'


def common_pods
    use_frameworks!
#    pod 'SSKit'
    pod 'SSKit', :git => 'http://code.smartstudy.com/chenyusen/SSKit.git'
    pod 'SnapKit'
    pod 'SDCycleScrollView', '~> 1.66'
    pod 'YYModel', :inhibit_warnings => true
    pod 'UICKeyChainStore', '~> 2.1.1'
#    pod 'Meiqia', '~> 3.4.2', :inhibit_warnings => true
    pod 'UMCCommon'
    pod 'UMCAnalytics'
    pod 'UMCShare/UI'
    pod 'UMCErrorCatch'
    pod 'UMCShare/Social/ReducedWeChat'
    pod 'UMCShare/Social/ReducedQQ'
    pod 'UMCShare/Social/ReducedSina'
    pod 'JPush'
    pod 'WMPageController'
    pod 'SSOpenID'
    pod 'SSPhotoBrowser', :git =>'git@code.smartstudy.com:tanxiao/SSPhotoBrowser.git'
    pod 'pop', '~> 1.0'
    pod 'lottie-ios'   
    pod 'LHPerformanceStatusBar'
    pod 'ZKUIKit'
    pod 'RealReachability'
    pod 'SSRobot-swift', :git =>'git@code.smartstudy.com:tanxiao/SSRobot-swift.git', :inhibit_warnings => true
    pod 'RongCloudIM/IMLib', '~> 2.8.24', :inhibit_warnings => true
    pod 'ZXingObjC', '~> 3.2.2'
    pod 'RealmSwift'
    pod 'ZMJImageEditor', :git =>'git@code.smartstudy.com:tanxiao/ZMJImageEditor.git'
    pod 'DeviceKit', :inhibit_warnings => true
    pod 'IQKeyboardManagerSwift'
    pod 'SensorsAnalyticsSDK'
    pod 'JTAppleCalendar'
    pod 'PFVideoPlayer', :git => 'https://gitee.com/MrErGe/PFVideoPlayer.git'  #:path => '../PFVideoPlayerDevRepo/PFVideoPlayer'
end

target 'xxd' do
    common_pods
end

target 'xxdTests' do
    common_pods
end
