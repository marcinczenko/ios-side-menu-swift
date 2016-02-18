# SideMenu iOS App

This project adopts the general idea presented in the project [SlideOutNavigation](http://www.raywenderlich.com/32054/how-to-create-a-slide-out-navigation-like-facebook-and-path). However, here faced additional challenges:

1. Our *center view controller* - a controller that presents the actual content and which slides to right in order to reveal the side menu (the *left view controller*) - is in our case a navigation controller. This view hierarchy is different than the one used in the *SlideOutNavigation* project.
2. The *SlideOutNavigation* project uses `xib` files for the UI design and then instantiates controller using UIViewController's `initWithNibName:bundle:` initializer. This is very convenient and quite portable, but in the PDFReader app I wanted to take a slightly different approach: PDFReader already uses story board - I wanted to see how we could use story boards to properly structure view containment.
3. The *SlideOutNavigation* project does not feature swipe gesture.
4. Animations and positioning are performed using `NSLayoutConstraint`.

These four challenges required to re-engineer the app in a number of areas and in what follows I will briefly discuss those.

> The remaining part of this file still need to be updated to Swift and to discussing using `NSLayoutConstraint` to manage positioning and animations. Will be updated soon.

### View Containment
In our story board we have now *Main View Controller* - `EPMainViewController` in code - as the initial controller. From the Object Library in the Interface Builder I dragged the *Container View* object and make it fill the whole view area of the Main View Controller. After you drag the *Container View*, Interface Builder will automatically create a child view controller and it will connect it to the Main View Controller with *embed* segue. I had to delete the child view controller and *ctrl-drag* from the *Container View* view object to our *Navigation Controller* (which in turn is the container for our *Document List Table View* controller. With this configuration, the app should work just as it would before as the embed segue will be performed automatically when out *Main View Controller* will be loading from the story board. When the `viewDidLoad:` for the *Main View Controller* will be called not only the parent but also the child will already be loaded and ready. In order to capture this new hierarchy, inside the `EPMainViewController` I keep the following *week* references:

    @property (nonatomic, weak) UINavigationController* centerNavigationController;
    @property (nonatomic, weak) EPDocumentListTableViewController* centerTableViewController;

These can be easily extracted from the current view hierarchy:

    self.centerNavigationController = self.childViewControllers[0];
    self.centerTableViewController = 
        (EPDocumentListTableViewController*)self.centerNavigationController.topViewController;

Our story board also contains the view controller for our menu, or left view: it is *Menu Table View Controller* - `EPMenuTableViewController` in code. Please notice that because it is not connected to any other view controller using segue (we could do something about it using custom segues, but we will follow a different approach here), we need to set its *Storyboard ID* property. In our case it will be `MenuTableViewController`. We use this identifier when instantiating the menu table view controller:

    UIStoryboard* storyboard = self.storyboard;
    self.leftTableViewController = [storyboard 
        instantiateViewControllerWithIdentifier:@"MenuTableViewController"];

Right after instantiating menu table view controller, we will make it a child of the Main View Controller, we will add its view to the view hierarchy and then immediately send it to back:

    [self addChildViewController:self.leftTableViewController];
    [self.leftTableViewController didMoveToParentViewController:self];
    [self.view addSubview:self.leftTableViewController.view];
    [self.view sendSubviewToBack:self.leftTableViewController.view];
    
After doing this, our view controller hierarchy is the following:

    Main View Controller
      |
      |--- Navigation Controller (childViewControllers[0])
      |		  |
      |		  |--- EPDocumentListTableViewController
      |							
      |--- EPMenuTableViewController (childViewControllers[1])

and the corresponding view hierarchy before sending the menu table view controller's view to back is:

    Main View Controller's view
      |
      |--- Container View
      |		   |
      |        |--- Navigation Controller's view
      |		   |
      |		   |--- EPDocumentListTableViewController's view (tableView)
      |
      |--- EPMenuTableViewController's view (tableView)

After sending the menu view controller's view to the back, the view hierarchy will look like this:

    Main View Controller's view
      |
      |--- EPMenuTableViewController's view (tableView)
      |
      |--- Container View
      		   |
               |--- Navigation Controller's view
      		   |
      		   |--- EPDocumentListTableViewController's view (tableView)

This indicates that in revealing the side menu, we will effectively move the *Container View*. It also indicates that it will be the *Container View* where we will attach our gesture recognizer. We will obtain the reference to the *Container View* using the `superview` property of our Navigation Controller which we know is the child of the *Container View*:

    self.centerNavigationController.view.superview;

### Gestures
Our side menu needs two types of gestures: a pan gesture when the user reveals the side menu by dragging it with the finger and a swipe gesture which let the user quickly reveal the side menu by swiping.
We will implement both gestures using just one gesture recognizer as this will simplify handling dependencies between them. For this purpose we will use - of course - `UIPanGestureRecognizer`. For the sake of decoupled design we wrap the `UIPanGestureRecognizer` in our own class `EPSideMenuPanGestureRecognizer`.

Now, if we left everything as it is now, the gesture recognizer associated with `EPDocumentListTableViewController` (`UIScrollViewPanGestureRecognizer`) starts recognizing touches at the same time *our* gesture recognizer does. A standard behavior is that only the one gesture recognizer to succeed, making all remaining gesture recognizers to fail. If more than one gesture recognizer recognizes its gesture, the one lower down the view hierarchy (the more top-most view) will take precedence. In our case, it means that if the gesture recognizer associated with the `EPDocumentListTableViewController`'s view has priority in recognizing its gesture causing *our* recognizer to fail. In our case, the `UIScrollViewPanGestureRecognizer` associated with `EPDocumentListTableViewController`'s view fails for horizontal gestures, which means *our* gesture recognizer will still have chance to succeed. Imagine, however what would happen if the gesture recognizer associated with `EPDocumentListTableViewController`'s view finds the horizontal panning interesting? In such a case, *our* gesture recognizer may have never had a chance to recognizer its gesture, rendering our side menu unresponsive to touch gestures. Also in our more forgiving case, one may prefer to shift the balance slightly towards *our* gesture recognizer. The reason for this may be to have a better control over the moment the touch should be recognized as a horizontal rather than vertical gesture.
To accomplish this, we will use the `UIGestureRecognizerDelegate` protocol and implement its two methods:

- `- (BOOL)gestureRecognizerShouldBegin:`, and
- `- (BOOL)gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:`

We will start with the second method. This method defines a *dependency* between two gesture recognizers. The first argument of this method is the gesture recognizer for which delegate has been registered, the second argument being another gesture recognizer that is about to successfully recognize its gesture. When this method is called we know that the *other* gesture recognizer is about to succeed and we may interfere with this by returning `YES`. This will cause other gesture recognizer to **wait** before concluding success in its gesture recognition till the moment *our* gesture recognizer declares failure. If *our* gesture recognizer succeeds in recognizing its gesture, the other gesture recognizer will fail, thus, giving *our* gesture recognizer priority. 

> In our implementation we return `YES` for each gesture recognizer pair, which means we decided to give *our* pan gesture recognizer priorities over all other, possibly conflicting, gesture recognizers. This does not cause any problem in our case, but may require more careful selection in a more complex scenario.

If we had only implemented `gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:`, however, we would not be able to scroll the main table view with our items. This is because every attempt to scroll would cause *our* gesture recognizer to succeed in the first place, rendering the other gesture recognizers inactive. We need a way to fail our gesture recognizer when we think the pan gesture is more appropriate for the other gesture recognizer. This is where we take advantage of the second delegate method mentioned above: `gestureRecognizerShouldBegin:`. This method allows us to cancel gesture recognizer that is about recognized its gesture and is about to succeed by returning `NO`.
In our case, we want *our* gesture recognizer to fail when its horizontal velocity is not considerably higher than its vertical velocity. We also do not want *our* gesture recognizer to succeed when the user is panning left and the menu is not yet visible:

    - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
    {
        CGPoint velocity = [self.panRecognizer velocityInView:self.panRecognizer.view];
        
        if (self.panRecognizer.view.frame.origin.x == 0 && velocity.x<0) {
            return NO;
        }
    
        if (abs(velocity.y)>100.0 && abs(velocity.x)<300.0) {
            return NO;
        }
    
        return YES;
    }

This way, we have more control over responsiveness of our side menu.

### Implementing swipe gesture
Our take on swipe is very simple. When the pan gesture ends, we measure the most recent velocity. If it exceeds hard-coded threshold value, we conclude that pan was a swipe. See the implementation of class `EPSideMenuPanGestureRecognizerStateEnded` for the details.

### Animation duration
We also use the most recent velocity when gesture recognition ends to compute the appropriate duration of the animation that reveals the side menu by animating the position of *Container View*. The speed is empirically normalized and its lowest value is also constrained to maintain an appropriate level of the responsiveness. See the implementation of the `EPSideMenuPanGestureRecognizerStateEnded` class, the method `computeAnimationDuration:` in the `EPSideMenuPanGestureRecognizerState` class, and the implementation of methods `movePanelRightWithDuration:` and `movePanelToOriginalPositionWithDuration` in class `EPMainViewController`.

### Other useful resources on gesture recognizers
- [Programming iOS 6, by Matt Neuburg][iOS6_MattNeuburg],
- [Hit-Testing in iOS][hit-testing-ios],
- [Apple Developer: Gesture Recognizers][apple-gesture-recognizers],
- [UIGestureRecognizerDelegate Protocol Reference][uigesturerecognizerdelegate]


[QuickLookFramework]: https://developer.apple.com/library/ios/documentation/QuickLook/Reference/QuickLookFrameworkReference_iPhoneOS/_index.html#//apple_ref/doc/uid/TP40009672
[QLPreviewController]: https://developer.apple.com/library/ios/documentation/NetworkingInternet/Reference/QLPreviewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40009657
[QLPreviewControllerDataSource]: https://developer.apple.com/library/ios/documentation/NetworkingInternet/Reference/QLPreviewControllerDataSource_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40009665
[iOS6_MattNeuburg]: http://www.apeth.com/iOSBook/ch18.html#_gesture_recognizers
[hit-testing-ios]: http://smnh.me/hit-testing-in-ios/
[apple-gesture-recognizers]: https://developer.apple.com/library/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/GestureRecognizer_basics/GestureRecognizer_basics.html#//apple_ref/doc/uid/TP40009541-CH2-SW2
[uigesturerecognizerdelegate]: https://developer.apple.com/library/ios/documentation/uikit/reference/UIGestureRecognizerDelegate_Protocol/Reference/Reference.html

