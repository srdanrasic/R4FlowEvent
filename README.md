R4FlowEvent
===========

Have you ever wanted to know why viewDidAppear: (or any other) really happened? Now you can.

R4FlowEvent extends UIViewController class with four additional view appearance methods that you can use to inspect why they occurred. Just add R4FlowEvent.[hm] files to your project and you'll get these methods on UIViewController:

```objective-c
- (void)viewWillAppear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent;
- (void)viewDidAppear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent;
- (void)viewWillDisappear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent;
- (void)viewDidDisappear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent;
```

For example, if you've ever wanted to do something only when your view appeared because some modal (presented) view controller was dismissed, now you can do it like this:

```objective-c
#import "R4FlowEvent.h"

...

- (void)viewDidAppear:(BOOL)animated flowEvent:(R4FlowEvent *)flowEvent
{
  // No need to call super

  if (flowEvent.type == kR4FlowEventTypeDismissViewController) {
    // I appeared because some presented view controller was dismissed
  }
}
```

You can also schedule custom signals if you need to handle custom view controller presentations. You do this just before triggering beginAppearanceTransition: methods, like this:
  
```objective-c
[R4FlowEvent signalCustomFlowEvent:[R4FlowEvent customFlowEventWithType:@"MyPageViewControllerSwipe"]];

[someCurrentViewContainer beginAppearanceTransition:NO animated:YES];
[someNextViewContainer beginAppearanceTransition:YES animated:YES]; 
```
    
As simple as that :)
