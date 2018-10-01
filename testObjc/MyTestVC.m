//
//  ViewController.m
//  testObjc
//
//  Created by DerekYang on 2018/10/1.
//  Copyright © 2018年 DKY. All rights reserved.
//

#import "MyTestVC.h"



@interface MyTestVC ()

@end

@implementation MyTestVC



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    UINavigationBar* navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 50)];
//    
//    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"karthik"];
//    // [navbar setBarTintColor:[UIColor lightGrayColor]];
//    UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onTapCancel:)];
//    navItem.leftBarButtonItem = cancelBtn;
//    
//    UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onTapDone:)];
//    navItem.rightBarButtonItem = doneBtn;
//    
//    [navbar setItems:@[navItem]];
//    [self.view addSubview:navbar];
    
    self.m_topConstraint = nil;
    self.m_isHiddenBar = true;
    
    UIView *myView = [[UIView alloc] initWithFrame: CGRectZero];
    myView.backgroundColor = UIColor.yellowColor;
    [self.view addSubview: myView];
    myView.translatesAutoresizingMaskIntoConstraints = false;
    if (@available(iOS 11.0, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        [myView.topAnchor constraintEqualToAnchor: guide.topAnchor].active = true;
        [myView.bottomAnchor constraintEqualToAnchor: guide.bottomAnchor].active = true;
        [myView.leadingAnchor constraintEqualToAnchor: guide.leadingAnchor].active = true;
        [myView.trailingAnchor constraintEqualToAnchor: guide.trailingAnchor].active = true;
    } else {
        // Fallback on earlier versions
        UILayoutGuide *guide = self.view.layoutMarginsGuide;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.m_topConstraint = [myView.topAnchor constraintEqualToAnchor: self.view.topAnchor];
        self.m_topConstraint.active = true;
        [myView.bottomAnchor constraintEqualToAnchor: guide.bottomAnchor].active = true;
        [myView.leadingAnchor constraintEqualToAnchor: guide.leadingAnchor].active = true;
        [myView.trailingAnchor constraintEqualToAnchor: guide.trailingAnchor].active = true;
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(deviceRotated) //接收到該Notification時要call的function
     name: UIDeviceOrientationDidChangeNotification
     object: nil];
}

-(void)onTapDone:(UIBarButtonItem*)item{
    NSLog(@"Done");
    
}

-(void)onTapCancel:(UIBarButtonItem*)item{
    NSLog(@"Cancel");
}

-(void)deviceRotated {
    UIDevice *device = UIDevice.currentDevice;
    switch(device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            self.m_topConstraint.constant = 0;
            break;
            
        case UIDeviceOrientationPortrait:
            if(self.m_isHiddenBar) {
                self.m_topConstraint.constant = 20;
            } else {
                self.m_topConstraint.constant = 0;
            }
            break;
            
        default:
            break;
    };
}

- (void) dealloc {
    NSLog(@"The instance of MyViewController was deallocated");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
