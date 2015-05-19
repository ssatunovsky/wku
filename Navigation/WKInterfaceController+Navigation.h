#import <WatchKit/WatchKit.h>

@interface WKInterfaceController (Navigation)

/**
 Interface controllers hierarrchy, where [0] is rootInterfaceController lastObject is topInterfaceController
*/
+(NSArray *) interfaceControllers;

/**
 Root interface controller
*/
+(WKInterfaceController *) rootInterfaceController;

/**
 Current vissible controller
*/
+(WKInterfaceController *) topInterfaceController;

/** 
 This controller's child controllers
*/
@property (readonly, strong, nonatomic) NSArray *interfaceControllers;

/**
 Root interface controller
*/
@property (readonly, strong, nonatomic) WKInterfaceController *rootInterfaceController;

/**
 Current vissible controller
*/
@property (readonly, strong, nonatomic) WKInterfaceController *topInterfaceController;

/**
 Previous controller in controllers hierarrchy
*/
@property (readonly, strong, nonatomic) WKInterfaceController *parentInterfaceController;

@end
