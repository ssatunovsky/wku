#import "WKInterfaceController+Navigation.h"

#import <objc/runtime.h>

static char kWKUHelperAssociationKey;

@interface WKInterfaceControllerHelper : NSObject

@property (strong, nonatomic) NSArray *interfaceControllers;
@property (strong, nonatomic) WKInterfaceController *rootInterfaceController;
@property (strong, nonatomic) WKInterfaceController *topInterfaceController;

@property (strong, nonatomic) WKInterfaceController *parentInterfaceController;

@end

@implementation WKInterfaceControllerHelper

@end

@interface WKInterfaceController (Internal)

+(WKInterfaceControllerHelper *) sharedHelper;

@property (readonly, strong, nonatomic) WKInterfaceControllerHelper *sharedHelper;
@property (readwrite, strong, nonatomic) WKInterfaceControllerHelper *helper;
@property (readwrite, strong, nonatomic) WKInterfaceController *parentInterfaceController;

+(void) hookMethod: (SEL) original
          withHook: (SEL) hook;

-(void) wku_willActivate;

@end

@implementation WKInterfaceController (Navigation)

#pragma mark - hook
+(void) hookMethod: (SEL) original withHook: (SEL) hook {
    method_exchangeImplementations(class_getInstanceMethod(self, original), class_getInstanceMethod(self, hook));
}

#pragma mark - load
+(void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // willActivate hook
        [self hookMethod: @selector(willActivate)
                withHook: @selector(wku_willActivate)];
    });
}

#pragma mark - wku
#pragma mark - helper
+(WKInterfaceControllerHelper *) sharedHelper {
    static WKInterfaceControllerHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [WKInterfaceControllerHelper new];
    });
    return sharedHelper;
}

-(WKInterfaceControllerHelper *) sharedHelper {
    return [WKInterfaceController sharedHelper];
}

-(WKInterfaceControllerHelper *) helper {
    WKInterfaceControllerHelper *helper = objc_getAssociatedObject(self, &kWKUHelperAssociationKey);
    
    if(!helper) {
        self.helper = [WKInterfaceControllerHelper new];
    }
    
    return helper;
}

-(void) setHelper: (WKInterfaceControllerHelper *) helper {
    objc_setAssociatedObject(self, &kWKUHelperAssociationKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - controllers
+(NSArray *) interfaceControllers {
    return [WKInterfaceController sharedHelper].interfaceControllers;
}

-(NSArray *) interfaceControllers {
    if(self == self.rootInterfaceController) {
        return [WKInterfaceController sharedHelper].interfaceControllers;
    }
    
    NSRange range = { 0, 0 };
    for(WKInterfaceController *controller in [WKInterfaceController interfaceControllers]) {
        if(controller == self) {
            break;
        }
        
        ++range.location;
    }
    
    range.length = [WKInterfaceController interfaceControllers].count - range.location;
    
    if(!range.length) {
        // TODO: error here
        return @[];
    }
    
    return [[WKInterfaceController interfaceControllers] subarrayWithRange: range];
}

#pragma mark - root
+(WKInterfaceController *) rootInterfaceController {
    return [WKInterfaceController sharedHelper].rootInterfaceController;
}

-(WKInterfaceController *) rootInterfaceController {
    return [WKInterfaceController rootInterfaceController];
}

#pragma mark - top
+(WKInterfaceController *) topInterfaceController {
    return [WKInterfaceController sharedHelper].topInterfaceController;
}

-(WKInterfaceController *) topInterfaceController {
    return [WKInterfaceController topInterfaceController];
}

#pragma mark - parent
-(WKInterfaceController *) parentInterfaceController {
    return self.helper.parentInterfaceController;
}

-(void) setParentInterfaceController: (WKInterfaceController *) parentInterfaceController {
    self.helper.parentInterfaceController = parentInterfaceController;
}

#pragma mark - hooks
#pragma mark - lifecycle
-(void) wku_willActivate {
    // invoke original
    [self wku_willActivate];
    
    // if there is no root, this controller will become the root
    if(!self.sharedHelper.rootInterfaceController) {
        self.sharedHelper.rootInterfaceController = self;
    }
    
    // current controllers
    NSArray *controllers = [WKInterfaceController sharedHelper].interfaceControllers;
    
    // if we're going back
    if(self.topInterfaceController.parentInterfaceController == self) {
        [WKInterfaceController sharedHelper].interfaceControllers = [controllers subarrayWithRange: NSMakeRange(0, controllers.count - 1)];
    } else {
        self.helper.parentInterfaceController = self.sharedHelper.topInterfaceController;
        
        [WKInterfaceController sharedHelper].interfaceControllers = [controllers arrayByAddingObject: self];
    }
    
    // it will become top controller
    self.sharedHelper.topInterfaceController = self;
}


@end
