//
//  ViewController.m
//  CanvasEmojis
//
//  Created by Yash Kshirsagar on 9/21/16.
//  Copyright © 2016 Yash Kshirsagar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *trayView;
@property (nonatomic, assign) CGPoint trayOriginalCenter;
@property (nonatomic, assign) CGPoint trayCenterWhenOpen;
@property (nonatomic, assign) CGPoint trayCenterWhenClosed;
@property (nonatomic, strong) UIImageView *newlyEmojiFace;
@property (nonatomic, assign) CGPoint newlyEmojiOriginalCenter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.trayCenterWhenOpen = CGPointMake(self.trayView.center.x, self.view.frame.size.height - (self.trayView.frame.size.height/2));
   
    // move it to bottom of screen and peek arrow
    self.trayView.center = CGPointMake(self.trayView.center.x, self.view.frame.size.height + 48);

    self.trayCenterWhenClosed = self.trayView.center;
    self.trayOriginalCenter = self.trayView.center;

    self.trayView.layer.shadowOpacity = 0.4;
    self.trayView.layer.shadowOffset = CGSizeMake(0.0f, -5.0f);
    self.trayView.layer.shadowColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
    self.trayView.layer.masksToBounds = NO;
    self.trayView.layer.shadowRadius = 4.0f;
 }

- (IBAction)trayDrag:(UIPanGestureRecognizer *)sender {
    // Absolute (x,y) coordinates in parentView
    CGPoint translation = [sender translationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];

    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %@", NSStringFromCGPoint(translation));
        self.trayOriginalCenter = self.trayView.center;
        NSLog(@"began center:: %f", self.trayOriginalCenter.x);
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed at: %@", NSStringFromCGPoint(translation));
       
        self.trayView.center = CGPointMake(self.trayOriginalCenter.x,
                                      self.trayOriginalCenter.y + translation.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended at: %@", NSStringFromCGPoint(translation));
        if (velocity.y > 0) {
            NSLog(@" close it: ");
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.trayView.center = CGPointMake(self.trayOriginalCenter.x, self.trayCenterWhenClosed.y);
            } completion:^(BOOL finished) {}];
            
        } else {
            NSLog(@"open it ");
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.trayView.center = CGPointMake(self.trayOriginalCenter.x, self.trayCenterWhenOpen.y);

            } completion:^(BOOL finished) {}];
        }
    }
}

- (IBAction)emojiPan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];

    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"image pan began!");
        // Gesture recognizers know the view they are attached to
        UIImageView *imageView = (UIImageView *)sender.view;
        
        // Create a new image view that has the same image as the one currently panning
        self.newlyEmojiFace = [[UIImageView alloc] initWithImage:imageView.image];
        
        // Add the new face to the tray's parent view.
        [self.view addSubview:self.newlyEmojiFace];
        
        // Initialize the position of the new face.
        self.newlyEmojiFace.center = imageView.center;
        
        // Since the original face is in the tray, but the new face is in the
        // main view, you have to offset the coordinates
        CGPoint faceCenter = self.newlyEmojiFace.center;
        
        self.newlyEmojiFace.center = CGPointMake(faceCenter.x, faceCenter.y + self.trayView.frame.origin.y);
        self.newlyEmojiOriginalCenter = self.newlyEmojiFace.center;
        
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:1 options:0 animations:^{
            self.newlyEmojiFace.transform = CGAffineTransformScale(self.newlyEmojiFace.transform, 1.4, 1.4);
            self.newlyEmojiFace.alpha = 0.7;
    
        } completion:^(BOOL finished) {}];

    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"image pan changed..");
        
        
        self.newlyEmojiFace.center = CGPointMake(self.newlyEmojiOriginalCenter.x + translation.x, self.newlyEmojiOriginalCenter.y + translation.y);
        
      
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"image pan ended.. ");
        
        // remove image if placed inside tray view
        if ((self.newlyEmojiFace.frame.origin.y + self.newlyEmojiFace.frame.size.height) > self.trayView.frame.origin.y) {
            [self.newlyEmojiFace removeFromSuperview];
        } else {
            // all good. add tap gesture to remove from emoji on double-tap.
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:0 animations:^{
                self.newlyEmojiFace.transform = CGAffineTransformScale(self.newlyEmojiFace.transform, 0.7, 0.7);
                self.newlyEmojiFace.alpha = 1.0;
                
            } completion:^(BOOL finished) {}];
            
            UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmojiTap:)];
            
            gr.numberOfTapsRequired = 2; // double-tap to delete emoji.
            gr.delegate = (id)self.newlyEmojiFace;
            self.newlyEmojiFace.userInteractionEnabled = true;
            [self.newlyEmojiFace addGestureRecognizer:gr];
        }
    }
}

- (void) onEmojiTap: (UITapGestureRecognizer *)recognizer {
    NSLog(@"on double tap!! ");
    NSLog(@" recognizer:: %@", recognizer);
    [UIView animateWithDuration:0.25 animations:^{
        recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, 0.2, 0.2);
        recognizer.view.alpha = 0;
    } completion:^(BOOL finished) {
        [recognizer.view removeFromSuperview];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
