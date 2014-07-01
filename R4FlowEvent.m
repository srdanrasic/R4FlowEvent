/*
 R4FlowEvent is made available under the MIT License.
 
 Copyright (c) 2013 Srđan Rašić
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "R4FlowEvent.h"
#import <objc/runtime.h>

NSString * const kR4FlowEventTypeDefault = @"kR4FlowEventTypeDefault";
NSString * const kR4FlowEventTypePresentViewController = @"kR4FlowEventTypePresentViewController";
NSString * const kR4FlowEventTypeDismissViewController = @"kR4FlowEventTypeDismissViewController";
NSString * const kR4FlowEventTypeNavigationPush = @"kR4FlowEventTypeNavigationPush";
NSString * const kR4FlowEventTypeNavigationPop = @"kR4FlowEventTypeNavigationPop";
NSString * const kR4FlowEventTypeTabBarTabChanged = @"kR4FlowEventTypeTabBarTabChanged";

@interface UINavigationController (R4FlowEvent) @end
@interface UITabBarController (R4FlowEvent) @end

@interface R4FlowEvent ()
@property (nonatomic, assign, readwrite) NSString * const type;
@end

static R4FlowEvent *_sharedFlowEvent = nil;

@implementation R4FlowEvent

static void swizzleMethod(Class c, SEL orig, SEL new)
{
  Method origMethod = class_getInstanceMethod(c, orig);
  Method newMethod = class_getInstanceMethod(c, new);
  if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
    class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
  else
    method_exchangeImplementations(origMethod, newMethod);
}

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    swizzleMethod([UIViewController class], @selector(viewWillAppear:), @selector(_viewWillAppear:));
    swizzleMethod([UIViewController class], @selector(viewDidAppear:), @selector(_viewDidAppear:));
    swizzleMethod([UIViewController class], @selector(viewWillDisappear:), @selector(_viewWillDisappear:));
    swizzleMethod([UIViewController class], @selector(viewDidDisappear:), @selector(_viewDidDisappear:));
    
    swizzleMethod([UIViewController class], @selector(presentViewController:animated:completion:), @selector(_presentViewController:animated:completion:));
    swizzleMethod([UIViewController class], @selector(dismissViewControllerAnimated:completion:), @selector(_dismissViewControllerAnimated:completion:));
    swizzleMethod([UIViewController class], @selector(dismissModalViewControllerAnimated:), @selector(_dismissModalViewControllerAnimated:));
    
    swizzleMethod([UINavigationController class], @selector(pushViewController:animated:), @selector(_pushViewController:animated:));
    swizzleMethod([UINavigationController class], @selector(popViewControllerAnimated:), @selector(_popViewControllerAnimated:));
    swizzleMethod([UINavigationController class], @selector(popToViewController:animated:), @selector(_popToViewController:animated:));
    swizzleMethod([UINavigationController class], @selector(popToRootViewControllerAnimated:), @selector(_popToRootViewControllerAnimated:));
  
    swizzleMethod([UITabBarController class], @selector(setSelectedViewController:), @selector(_setSelectedViewController:));
    
    _sharedFlowEvent = [[R4FlowEvent alloc] init];
  });
}

+ (void)signalCustomFlowEvent:(R4FlowEvent *)customFlowEvent
{
  @synchronized(_sharedFlowEvent) {
    _sharedFlowEvent = customFlowEvent;
  }
}

+ (instancetype)customFlowEventWithType:(NSString * const)type
{
  R4FlowEvent *event = [[R4FlowEvent alloc] init];
  event.type = type;
  return event;
}

- (NSString *)description
{
  return [self.type copy];
}

@end

@implementation UIViewController (R4FlowEvent)

- (void)_viewWillAppear:(BOOL)animated
{
  [self viewWillAppear:animated flowEvent:_sharedFlowEvent];
  [self _viewWillAppear:animated];
}

- (void)_viewDidAppear:(BOOL)animated
{
  [self viewDidAppear:animated flowEvent:_sharedFlowEvent];
  [self _viewDidAppear:animated];
}

- (void)_viewWillDisappear:(BOOL)animated
{
  [self viewWillDisappear:animated flowEvent:_sharedFlowEvent];
  [self _viewWillDisappear:animated];
}

- (void)_viewDidDisappear:(BOOL)animated
{
  [self viewDidDisappear:animated flowEvent:_sharedFlowEvent];
  [self _viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent {}
- (void)viewDidAppear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent {}
- (void)viewWillDisappear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent {}
- (void)viewDidDisappear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent {}



- (void)_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
  _sharedFlowEvent.type = kR4FlowEventTypePresentViewController;
  [self _presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
  _sharedFlowEvent.type = kR4FlowEventTypeDismissViewController;
  [self _dismissViewControllerAnimated:flag completion:completion];
}

- (void)_dismissModalViewControllerAnimated:(BOOL)animated
{
  _sharedFlowEvent.type = kR4FlowEventTypeDismissViewController;
  [self _dismissModalViewControllerAnimated:animated];
}

@end


@implementation UINavigationController (R4FlowEvent)

- (void)_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  _sharedFlowEvent.type = kR4FlowEventTypeNavigationPush;
  [self _pushViewController:viewController animated:animated];
}

- (UIViewController *)_popViewControllerAnimated:(BOOL)animated
{
  _sharedFlowEvent.type = kR4FlowEventTypeNavigationPop;
  return [self _popViewControllerAnimated:animated];
}

- (NSArray *)_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  _sharedFlowEvent.type = kR4FlowEventTypeNavigationPop;
  return [self _popToViewController:viewController animated:animated];
}

- (NSArray *)_popToRootViewControllerAnimated:(BOOL)animated
{
  _sharedFlowEvent.type = kR4FlowEventTypeNavigationPop;
  return [self _popToRootViewControllerAnimated:animated];
}

@end


@implementation UITabBarController (R4FlowEvent)

- (void)_setSelectedViewController:(UIViewController *)selectedViewController
{
  if ([self.viewControllers containsObject:selectedViewController]) {
    _sharedFlowEvent.type = kR4FlowEventTypeTabBarTabChanged;
  }
  
  [self _setSelectedViewController:selectedViewController];
}

@end
