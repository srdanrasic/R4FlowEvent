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

#import <Foundation/Foundation.h>

extern NSString * const kR4FlowEventTypeDefault;
extern NSString * const kR4FlowEventTypePresentViewController;
extern NSString * const kR4FlowEventTypeDismissViewController;
extern NSString * const kR4FlowEventTypeNavigationPush;
extern NSString * const kR4FlowEventTypeNavigationPop;
extern NSString * const kR4FlowEventTypeTabBarTabChanged;


@interface R4FlowEvent : NSObject

@property (nonatomic, assign, readonly) NSString * const type;

+ (instancetype)customFlowEventWithType:(NSString * const)type;
+ (void)signalCustomFlowEvent:(R4FlowEvent *)customFlowEvent;

@end


@interface UIViewController (R4FlowEvent)

- (void)viewWillAppear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent;
- (void)viewDidAppear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent;
- (void)viewWillDisappear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent;
- (void)viewDidDisappear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent;

@end
