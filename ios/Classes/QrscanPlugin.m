#import "QrscanPlugin.h"
#if __has_include(<qrscan/qrscan-Swift.h>)
#import <qrscan/qrscan-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "qrscan-Swift.h"
#endif

@implementation QrscanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQrscanPlugin registerWithRegistrar:registrar];
}
@end
