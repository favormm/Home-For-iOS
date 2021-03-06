//
//  PSHMenuViewController.m
//  Home
//
//  Created by Kenny Tang on 4/22/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHMenuViewController.h"
#import "PSHFacebookDataService.h"
#import "PSHMenuGestureRecognizer.h"

#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>

static NSInteger const kPSHMenuViewControllerLaunchPhoneButton = 1112;
static NSInteger const kPSHMenuViewControllerLaunchMailButton = 1113;
static NSInteger const kPSHMenuViewControllerLaunchMapsButton = 1114;

static NSInteger const kPSHMenuViewControllerLaunchBrowserButton = 1115;
static NSInteger const kPSHMenuViewControllerLaunchMessengerButton = 1116;
static NSInteger const kPSHMenuViewControllerLaunchYoutubeButton = 1117;

static NSInteger const kPSHMenuViewControllerLaunchMusicButton = 1118;
static NSInteger const kPSHMenuViewControllerLaunchInstagramButton = 1119;
static NSInteger const kPSHMenuViewControllerLaunchTwitterButton = 1120;


@interface PSHMenuViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView * menuButtonView;
@property (nonatomic, weak) IBOutlet UIImageView * menuButtonImageView;

@property (nonatomic, weak) IBOutlet UIView * messengerButtonView;
@property (nonatomic, weak) IBOutlet UIImageView * messengerButtonImageView;

@property (nonatomic, weak) IBOutlet UIView * notificationsButtonView;

@property (nonatomic, weak) IBOutlet UIView * launcherButtonView;
@property (nonatomic, weak) IBOutlet UIView * launcherMenuView;

@property (nonatomic) BOOL menuExpanded;

@property (nonatomic, strong) NSString * ownGraphID;

@property (nonatomic, strong) PSHMenuGestureRecognizer * menuGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer * menuTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer * menuLongGestureRecognizer;


@property (nonatomic) CGRect defaultMenuButtonFrame;
@property (nonatomic) CGRect defaultMessengerButtonFrame;
@property (nonatomic) CGRect defaultNotificationsButtonFrame;
@property (nonatomic) CGRect defaultLauncherButtonFrame;

- (IBAction)launchAppButtonTapped:(id)sender;

- (IBAction)statusUpdateButtonTapped:(id)sender;
- (IBAction)photosButtonTapped:(id)sender;
- (IBAction)checkinButtonTapped:(id)sender;
- (IBAction)reloadButtonTapped:(id)sender;



@end

@implementation PSHMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initMenuButton];
    [self initMessengerButton];
    [self initAppLauncherButton];
    [self initAppLauncher];
    [self initNotificationsButton];
    self.menuExpanded = NO;
    
    self.menuGestureRecognizer = [[PSHMenuGestureRecognizer alloc] init];
    [self.menuGestureRecognizer addTarget:self action:@selector(menuGestureRecognizerAction:)];
    
    self.menuGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.menuGestureRecognizer];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    UISwipeGestureRecognizer * swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [swipeGestureRecognizer addTarget:self action:@selector(viewSwiped:)];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initMenuButton {
    self.defaultMenuButtonFrame = self.menuButtonView.frame;
    self.menuButtonView.tag = kPSHMenuViewControllerMenuButtonViewTag;
    [self.menuButtonView.layer setCornerRadius:30.0f];
    [self.menuButtonView.layer setMasksToBounds:YES];
    [self.menuButtonView.layer setBorderWidth:2.0f];
    [self.menuButtonView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    self.menuButtonView.backgroundColor = [UIColor clearColor];
    self.menuButtonImageView.backgroundColor = [UIColor blackColor];
    
    FetchProfileSuccess fetchProfileSuccess =^(NSString * graphID, NSString * avartarImageURL, NSError * error){
        self.ownGraphID = graphID;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage * profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avartarImageURL]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.menuButtonImageView.image = profileImage;
            });
        });
    };
    PSHFacebookDataService * facebookDataService = [PSHFacebookDataService sharedService];
    [facebookDataService fetchOwnProfile:fetchProfileSuccess];
    
    self.menuTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    self.menuTapGestureRecognizer.delegate = self;
    [self.menuTapGestureRecognizer addTarget:self action:@selector(menuButtonTapped:)];
    [self.menuButtonView addGestureRecognizer:self.menuTapGestureRecognizer];
    
    self.menuLongGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    self.menuLongGestureRecognizer.delegate = self;
    self.menuLongGestureRecognizer.minimumPressDuration = .5f;
    [self.menuLongGestureRecognizer addTarget:self action:@selector(menuButtonLongPressed:)];
    [self.menuButtonView addGestureRecognizer:self.menuLongGestureRecognizer];
    
    
    
}

- (void) initMessengerButton {
    [self.messengerButtonView.layer setCornerRadius:45.0f/2];
    [self.messengerButtonView.layer setMasksToBounds:YES];
    [self.messengerButtonView.layer setBorderWidth:.5f];
    [self.messengerButtonView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.messengerButtonView.backgroundColor = [UIColor lightGrayColor];
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateShowMessenger)];
    [self.messengerButtonView addGestureRecognizer:tapRecognizer];
    
}

- (void) initAppLauncherButton {
    [self.launcherButtonView.layer setCornerRadius:45.0f/2];
    [self.launcherButtonView.layer setMasksToBounds:YES];
    [self.launcherButtonView.layer setBorderWidth:.5f];
    [self.launcherButtonView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.launcherButtonView.backgroundColor = [UIColor lightGrayColor];
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateShowLauncher)];
    [self.launcherButtonView addGestureRecognizer:tapRecognizer];
    
}

- (void) initAppLauncher {
    self.launcherMenuView.hidden = YES;
    UISwipeGestureRecognizer * swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [swipeGestureRecognizer addTarget:self action:@selector(appLauncherSwipedDown:)];
    [self.launcherMenuView addGestureRecognizer:swipeGestureRecognizer];
    
}

- (void) initNotificationsButton {
    [self.notificationsButtonView.layer setCornerRadius:45.0f/2];
    [self.notificationsButtonView.layer setMasksToBounds:YES];
    [self.notificationsButtonView.layer setBorderWidth:.5f];
    [self.notificationsButtonView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.notificationsButtonView.backgroundColor = [UIColor lightGrayColor];
    
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateShowNotifications)];
    [self.notificationsButtonView addGestureRecognizer:tapRecognizer];
}

- (void)menuButtonLongPressed:(UILongPressGestureRecognizer*)longRecognizer {
    if (longRecognizer.state == UIGestureRecognizerStateBegan){
        if (self.menuExpanded){
            [self animateHideMenuButtons];
        }else{
            [self animateExpandMenuButtons];
        }
    }else{
        [self animateHideMenuButtons];
        
    }
}

- (void) menuGestureRecognizerAction:(PSHMenuGestureRecognizer*)recognizer {
//    NSLog(@"menuGestureRecognizerAction state: %i", recognizer.state);
    CGRect launcherFrame = self.launcherButtonView.frame;
    CGRect messengerFrame = self.messengerButtonView.frame;
    CGRect notificationFrame = self.notificationsButtonView.frame;
    

    if (recognizer.state == UIGestureRecognizerStateBegan){
        
        launcherFrame = self.launcherButtonView.frame;
        messengerFrame = self.messengerButtonView.frame;
        notificationFrame = self.notificationsButtonView.frame;
    
    } else if (recognizer.state == UIGestureRecognizerStateChanged){
//        NSLog(@"UIGestureRecognizerStateChanged");
        CGPoint currentTouchPoint = [recognizer locationInView:self.view];
        if (CGRectContainsPoint(self.defaultLauncherButtonFrame, currentTouchPoint)){
            if (CGRectEqualToRect(self.launcherButtonView.frame, self.defaultLauncherButtonFrame)){
                [self animateShowLauncher];
                [self resetMenuButton];
//                [self animateHideMenuButtons];
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
            
        }else if (CGRectContainsPoint(self.defaultMessengerButtonFrame, currentTouchPoint)){
            if (CGRectEqualToRect(self.messengerButtonView.frame, self.defaultMessengerButtonFrame)){
                [self animateShowMessenger];
                [self animateHideMenuButtons];
                [self resetMenuButton];
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
            
        }else if (CGRectContainsPoint(self.defaultNotificationsButtonFrame, currentTouchPoint)){
            if (CGRectEqualToRect(self.notificationsButtonView.frame, self.defaultNotificationsButtonFrame)){
                [self animateShowNotifications];
                [self animateHideMenuButtons];
                [self resetMenuButton];
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
        }else{
            CGRect upperFrameRect = self.view.frame;
            upperFrameRect.size.height = upperFrameRect.size.height/1.5;
            if (CGRectContainsPoint(upperFrameRect, currentTouchPoint)){
                [self animateHideMenuButtonsFollowTouchPoint:currentTouchPoint];
                
            }
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"UIGestureRecognizerStateEnded");
        
        CGPoint currentTouchPoint = [recognizer locationInView:self.view];
        CGRect upperFrameRect = self.view.frame;
        upperFrameRect.size.height = upperFrameRect.size.height/1.5;
        if (CGRectContainsPoint(upperFrameRect, currentTouchPoint)){
            [self animateHideMenuButtonsFollowTouchPoint:currentTouchPoint];
        }
        if (!CGRectEqualToRect(self.launcherButtonView.frame, self.defaultLauncherButtonFrame)){
            [self resetMenuButton];
            [self animateHideMenuButtons];
        }
        
//            [self resetMenuButton];
//            [self animateHideMenuButtons];
        
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed){
        NSLog(@"UIGestureRecognizerStateFailed");
        [self resetMenuButton];
        [self animateHideMenuButtons];
        
    }
}

- (void)menuButtonTapped:(UITapGestureRecognizer*)longRecognizer {
    if (self.menuExpanded){
        [self resetMenuButton];
        [self animateHideMenuButtons];
    }else{
        [self animateExpandMenuButtons];
    }

}

- (void) animateShowLauncher {
    NSLog(@"animateShowLauncher");
    [self.view bringSubviewToFront:self.launcherMenuView];
    
    CGRect origLauncherMenuRect = self.launcherMenuView.frame;
    origLauncherMenuRect.origin.y = 0.0f;
    
    if (self.launcherMenuView.frame.origin.y == 0.0f){
        // set it down to bring it up
        CGRect destLauncherMenuRect = self.launcherMenuView.frame;
        destLauncherMenuRect.origin.y = self.launcherMenuView.frame.size.height;
        self.launcherMenuView.frame = destLauncherMenuRect;
    }
    self.launcherMenuView.hidden = NO;
    self.launcherMenuView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.launcherMenuView.frame = origLauncherMenuRect;
        self.launcherMenuView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        //
    }];
    
}


- (void) animateHideLauncher {
    NSLog(@"animateHideLauncher");
    
    CGRect destLauncherMenuRect = self.launcherMenuView.frame;
    destLauncherMenuRect.origin.y = self.launcherMenuView.frame.size.height;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.launcherMenuView.frame = destLauncherMenuRect;
        self.launcherMenuView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.launcherMenuView.hidden = YES;
    }];
}


- (void) animateShowMessenger {
    NSLog(@"animateShowMessenger");
    NSURL *url = [NSURL URLWithString:@"fb-messenger://compose"];
    [[UIApplication sharedApplication] openURL:url];
}


- (void) animateShowNotifications {
    NSLog(@"animateShowNotifications");
    NSURL *url = [NSURL URLWithString:@"fb://notifications"];
    [[UIApplication sharedApplication] openURL:url];
}


- (void) resetMenuButton {
    [UIView animateWithDuration:0.2f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.menuButtonView.frame = CGRectMake(130.0f, 474.0f, self.menuButtonView.frame.size.width, self.menuButtonView.frame.size.height);
    } completion:^(BOOL finished) {
        //
    }];
}

- (void) animateExpandMenuButtons {
    
    
    CGRect messengerButtonViewDestFrame = self.messengerButtonView.frame;
    messengerButtonViewDestFrame.origin.x = 30.0f;
    
    CGRect launcherButtonViewDestFrame = self.launcherButtonView.frame;
    launcherButtonViewDestFrame.origin.y = 360.0f;
    self.launcherButtonView.alpha = 0.0f;
    
    CGRect notificationsViewDestFrame = self.notificationsButtonView.frame;
    notificationsViewDestFrame.origin.x = 240.0f;
    self.notificationsButtonView.alpha = 0.0f;
    
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.messengerButtonView.frame = messengerButtonViewDestFrame;
        self.launcherButtonView.frame = launcherButtonViewDestFrame;
        self.notificationsButtonView.frame = notificationsViewDestFrame;
        
        self.defaultMessengerButtonFrame = messengerButtonViewDestFrame;
        self.defaultNotificationsButtonFrame = notificationsViewDestFrame;
        self.defaultLauncherButtonFrame = launcherButtonViewDestFrame;
        
        self.launcherButtonView.alpha = 1.0f;
        self.notificationsButtonView.alpha = 1.0f;
        self.messengerButtonView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        // nothing
        self.menuExpanded = YES;
    }];
}

- (void) animateHideMenuButtonsFollowTouchPoint:(CGPoint)currentTouchPoint {
    
    CGRect messengerButtonViewFrame = self.messengerButtonView.frame;
    CGRect notificationsButtonViewFrame = self.notificationsButtonView.frame;
    CGRect launcherButtonViewFrame = self.launcherButtonView.frame;
    
    messengerButtonViewFrame.origin = CGPointMake(currentTouchPoint.x- messengerButtonViewFrame.size.width/1.1, currentTouchPoint.y- messengerButtonViewFrame.size.height/1.1);
    
    notificationsButtonViewFrame.origin = CGPointMake(currentTouchPoint.x- notificationsButtonViewFrame.size.width/1.1, currentTouchPoint.y- notificationsButtonViewFrame.size.height/1.1);
    
    launcherButtonViewFrame.origin = CGPointMake(currentTouchPoint.x- launcherButtonViewFrame.size.width/1.1, currentTouchPoint.y- launcherButtonViewFrame.size.height/1.1);
    
    
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.messengerButtonView.frame = messengerButtonViewFrame;
        
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.notificationsButtonView.frame = notificationsButtonViewFrame;
        
    } completion:^(BOOL finished) {
    }];

    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.launcherButtonView.frame = launcherButtonViewFrame;
        
    } completion:^(BOOL finished) {
    }];
    

}

- (void) animateHideMenuButtons {
    CGRect messengerButtonViewDestFrame = self.messengerButtonView.frame;
    messengerButtonViewDestFrame.origin.x = 145.0f;
    messengerButtonViewDestFrame.origin.y = 485.0f;
    
    CGRect launcherButtonViewDestFrame = self.launcherButtonView.frame;
    launcherButtonViewDestFrame.origin.x = 138.0f;
    launcherButtonViewDestFrame.origin.y = 474.0f;
    
    CGRect notificationsViewDestFrame = self.notificationsButtonView.frame;
    notificationsViewDestFrame.origin.x = 145.0f;
    notificationsViewDestFrame.origin.y = 485.0f;
    
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.messengerButtonView.frame = messengerButtonViewDestFrame;
        self.launcherButtonView.frame = launcherButtonViewDestFrame;
        self.notificationsButtonView.frame = notificationsViewDestFrame;
        
        self.launcherButtonView.alpha = 0.0f;
        self.notificationsButtonView.alpha = 0.0f;
        self.messengerButtonView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        // nothing
        self.menuExpanded = NO;

    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ((([gestureRecognizer isEqual:self.menuLongGestureRecognizer]) && ([otherGestureRecognizer isEqual:self.menuGestureRecognizer])) ||
          (([gestureRecognizer isEqual:self.menuTapGestureRecognizer]) && ([otherGestureRecognizer isEqual:self.menuGestureRecognizer]))){
        return YES;
    }else{
        return NO;
    }
}

- (void)appLauncherSwipedDown:(UISwipeGestureRecognizer*)swipeGestureRecognizer {
    if(!self.launcherMenuView.hidden){
        [self animateHideLauncher];
    }
}


- (IBAction)launchAppButtonTapped:(UIButton*)sender {
    
    NSURL * url = nil;
    switch (sender.tag) {
            
        case kPSHMenuViewControllerLaunchPhoneButton:
            url = [NSURL URLWithString:@"tel:1-408-111-1111"];
            break;
        case kPSHMenuViewControllerLaunchMailButton:
            url = [NSURL URLWithString:@"mailto:"];
            break;
        case kPSHMenuViewControllerLaunchMapsButton:
            url = [NSURL URLWithString:@"maps:"];
            break;
        case kPSHMenuViewControllerLaunchBrowserButton:
            url = [NSURL URLWithString:@"http://facebook.com"];
            break;
        case kPSHMenuViewControllerLaunchMessengerButton:
            url = [NSURL URLWithString:@"sms:"];
            break;
        case kPSHMenuViewControllerLaunchYoutubeButton:
            url = [NSURL URLWithString:@"http://youtube.com"];
            break;
        case kPSHMenuViewControllerLaunchMusicButton:
            url = [NSURL URLWithString:@"music:"];
            break;
        case kPSHMenuViewControllerLaunchInstagramButton:
            url = [NSURL URLWithString:@"instagram://app"];
            break;
        case kPSHMenuViewControllerLaunchTwitterButton:
            url = [NSURL URLWithString:@"twitter://"];
            break;
        default:
            break;
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    
    
    
//    void (*openApp)(CFStringRef, Boolean);
//    void *hndl = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices");
//    openApp = dlsym(hndl, "SBSLaunchApplicationWithIdentifier");
//    
//    switch (sender.tag) {
//        case kPSHMenuViewControllerLaunchBrowserButton:
//            openApp(CFSTR("com.apple.mobilesafari"), FALSE);
//            break;
//        case kPSHMenuViewControllerLaunchCameraButton:
//            openApp(CFSTR("com.apple.camera"), FALSE);
//            break;
//        case kPSHMenuViewControllerLaunchPhotosButton:
//            openApp(CFSTR("com.apple.mobileslideshow"), FALSE);
//            break;
//            
//        default:
//            break;
//    }
    
    
//    openApp(CFSTR("com.apple.Preferences"), FALSE);
//    openApp(CFSTR("com.apple.mobileslideshow"), FALSE);
}

- (void) viewSwiped:(UISwipeGestureRecognizer*) swipeGestureRecognizer {
    if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        if ([self.delegate respondsToSelector:@selector(menuViewController:viewSwipedToLeft:)]){
            [self.delegate menuViewController:self viewSwipedToLeft:YES];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(menuViewController:viewSwipedToRight:)]){
            [self.delegate menuViewController:self viewSwipedToRight:YES];
        }
    }
}

- (void) viewTapped:(UITapGestureRecognizer*) tapGestureRecognizer {
    if (self.launcherMenuView.hidden){
        if ([self.delegate respondsToSelector:@selector(menuViewController:menuViewTapped:)]){
            [self.delegate menuViewController:self menuViewTapped:YES];
        }
    }
}

- (IBAction)statusUpdateButtonTapped:(id)sender {
    
//    NSString * urlString = [NSString stringWithFormat:@"fb://publish/profile/%@?text=awesome!", self.ownGraphID];
//    
//    NSURL * url = [NSURL URLWithString:urlString];
//    if ([[UIApplication sharedApplication] canOpenURL:url]){
//        [[UIApplication sharedApplication] openURL:url];
//    }

    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString * initalTextString = @"Home is awesome.";
    [composeViewController setInitialText:initalTextString];
    [self presentViewController:composeViewController animated:YES completion:^{
        // 
    }];
    
}

- (IBAction)photosButtonTapped:(id)sender {
    NSURL * url = [NSURL URLWithString:@"fb6628568379snap://"];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

- (IBAction)checkinButtonTapped:(id)sender {
    NSURL * url = [NSURL URLWithString:@"fb://place/create"];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

- (IBAction)reloadButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(menuViewController:reloadButtonTapped:)]){
        [self.delegate menuViewController:self reloadButtonTapped:YES];
    }
}


@end
