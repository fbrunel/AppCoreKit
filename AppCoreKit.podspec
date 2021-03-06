Pod::Spec.new do |s|

  s.name         = "AppCoreKit"
  s.version      = "3.0.1"
  s.summary      = "AppCoreKit is an application framework designed to improve productivity while creating Apps for iOS."
  s.homepage     = "https://github.com/smorel/AppCoreKit"
  s.license      = { :type => 'Apache Licence 2.0', :file => 'LICENSE.txt' }
  s.author       = { 'Sebastien Morel' => 'morel.sebastien@gmail.com' }
  s.source       = { :git => 'https://github.com/smorel/AppCoreKit.git', :tag => 'v3.0.1' }
  s.platform     = :ios, '7.0'
  s.header_dir   = "AppCoreKit"

  s.description = 'AppCoreKit is an application framework designed to improve productivity while creating Apps for iOS. This is the result of a 4 years experience at Wherecloud and is a production framework that shipped more than 20 apps. AppCoreKit does not offer out of the box UI components but the technology to help you: Manage your data, Automatic serialization (KeyValue Store, Core Data), Objective-C runtime apis, Type and data structure conversions, View controllers and containers, Ui vs. Models synchronization with bindings, Appearance customization with cascading stylesheets, Responsive view layouts with a horizontal/vertical box model, Forms with automatic sizing and custom layouts, Maps, Network, And more. Keep in mind that AppCoreKit is a toolbox. It is non intrusive so that you can cherry pick features and learn how to use it at your own pace. Screen Cast and high level description of the framework are available at http://www.appcorekit.net. A sample repository with binary versions of the framework is available at https://github.com/wherecloud/appcorekit-samples'


  s.default_subspec = 'All'

  s.frameworks =  'UIKit', 'Foundation', 'CoreImage', 'CoreGraphics', 'AddressBook', 'CoreData', 'QuartzCore', 'CoreLocation', 'MapKit', 'MediaPlayer', 'CoreFoundation', 'CFNetwork', 'SystemConfiguration', 'MobileCoreServices', 'Security', 'AdSupport', 'Accelerate', 'CoreMotion'

  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2', 'OTHER_LDFLAGS' => '-ObjC -all_load -lxml2 -licucore -lz -lc++ -weak_library /usr/lib/libstdc++.dylib' } 


  s.dependency 'TouchXML'
  s.dependency 'RegexKitLite'
  s.dependency 'Reachability'
  s.dependency 'SVPullToRefresh'
  
  s.requires_arc = false

  s.subspec 'JSONKit' do |f|    
    f.source_files = 'Vendor/JSONKit.{h,m}'
  end

  s.subspec 'Foundation' do |f|    
    f.source_files = 'Classes/Foundation/**/*.{h,m,mm}'
    f.private_header_files = 'Classes/Foundation/Private/**/*.{h}'
    f.exclude_files = "Classes/Foundation/Public/TypeAhead/*.{h,m,mm}"
    f.resources = 'Resources/**/*'
    f.dependency 'AppCoreKit/JSONKit'
  end


  s.subspec 'Animation' do |ani|    
    ani.source_files = 'Classes/Animation/**/*.{h,m,mm}'
    ani.private_header_files = 'Classes/Animation/Private/**/*.{h}'
    ani.dependency 'AppCoreKit/Foundation'
  end

  s.subspec 'AddressBook' do |a|    
    a.source_files = 'Classes/AdressBook/**/*.{h,m,mm}'
    #a.private_header_files = 'Classes/AdressBook/Private/**/*.{h}'
    a.dependency 'AppCoreKit/Foundation'
  end

  s.subspec 'Location' do |l|    
    l.source_files = 'Classes/Location/**/*.{h,m,mm}'
    #l.private_header_files = 'Classes/Location/Private/**/*.{h}'
    l.dependency 'AppCoreKit/Foundation'
  end

  s.subspec 'Mock' do |mo|    
    mo.source_files = 'Classes/Mock/**/*.{h,m,mm}'
    #mo.private_header_files = 'Classes/Mock/Private/**/*.{h}'
    mo.dependency 'AppCoreKit/Foundation'
  end

  s.subspec 'CoreData' do |c|    
    c.source_files = 'Classes/CoreData/**/*.{h,m,mm}'
    c.private_header_files = 'Classes/CoreData/Private/**/*.{h}'
    c.dependency 'AppCoreKit/Foundation'
  end

  s.subspec 'Binding' do |b|    
    b.source_files = 'Classes/Bindings/**/*.{h,m,mm}'
    b.private_header_files = 'Classes/Bindings/Private/**/*.{h}'
    b.dependency 'AppCoreKit/Foundation'
  end
  
  s.subspec 'Mapping' do |ma|
      ma.source_files = 'Classes/Mappings/**/*.{h,m,mm}'
      #ma.private_header_files = 'Classes/Mappings/Private/**/*.{h}'
      ma.dependency 'AppCoreKit/Foundation'
  end
  
  s.subspec 'Network' do |n|
      n.source_files = 'Classes/Network/**/*.{h,m,mm}'
      #n.private_header_files = 'Classes/Network/Private/**/*.{h}'
      n.dependency 'AppCoreKit/Mapping'
  end

  s.subspec 'Style' do |st|    
    st.source_files = 'Classes/Styles/**/*.{h,m,mm}'
    st.private_header_files = 'Classes/Styles/Private/**/*.{h}'
    st.dependency 'AppCoreKit/Network'
    st.dependency 'AppCoreKit/Binding'
  end

  s.subspec 'Layout' do |la|    
    la.source_files = 'Classes/Layout/**/*.{h,m,mm}'
    #la.private_header_files = 'Classes/Layout/Private/**/*.{h}'
    la.dependency 'AppCoreKit/Style'
  end


  s.subspec 'Media' do |m|    
    m.source_files = 'Classes/Media/**/*.{h,m,mm}'
    #m.private_header_files = 'Classes/Media/Private/**/*.{h}'
    m.dependency 'AppCoreKit/Foundation'
  end

  # AppCoreKit still has a dependency on debugger in CKViewController
  # therefore, we temporarilly embbed the debugger with the UI Module
  # wich adds a dependency on CoreData
  s.subspec 'UI' do |u|    
    u.source_files = 'Classes/UI/**/*.{h,m,mm}', 'Classes/Debugger/**/*.{h,m,mm}'
    u.private_header_files = 'Classes/UI/Private/**/*.{h}', 'Classes/Debugger/Private/**/*.{h}'
    u.dependency 'AppCoreKit/Layout'
    u.dependency 'AppCoreKit/CoreData'
    u.dependency 'AppCoreKit/Animation'
  end
  
  s.subspec 'Debugger' do |db|
      db.source_files = 'Classes/Debugger/**/*.{h,m,mm}'
      db.private_header_files = 'Classes/Debugger/Private/**/*.{h}'
      db.dependency 'AppCoreKit/UI'
  end

  s.subspec 'All' do |al|    
    al.source_files = 'Classes/AppCoreKit.h'
    al.dependency 'AppCoreKit/AddressBook'
    al.dependency 'AppCoreKit/Location'
    al.dependency 'AppCoreKit/Mock'
    al.dependency 'AppCoreKit/Debugger'
    al.dependency 'AppCoreKit/Media'
  end

  s.preserve_path = "Documentation/CodeSnippets/*", "Documentation/File Templates/*"
  
  s.prepare_command = <<-CMD
                        sudo mkdir -p "$HOME/Library/Developer/Xcode/Templates/File Templates/"
                        sudo mkdir -p "$HOME/Library/Developer/Xcode/UserData/CodeSnippets/"
                        sudo cp -rf "Documentation/File Templates/" "$HOME/Library/Developer/Xcode/Templates/File Templates/"
                        sudo cp -rf "Documentation/CodeSnippets/" "$HOME/Library/Developer/Xcode/UserData/CodeSnippets/"
                   CMD

end
