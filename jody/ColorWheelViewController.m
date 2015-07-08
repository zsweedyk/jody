//
//  ViewController.m
//  hereAndNow
//
//  Created by Z Sweedyk on 7/6/15.
//  Copyright (c) 2015 Z Sweedyk. All rights reserved.
//

#import "ColorWheelViewController.h"
#import "ColorWheelView.h"

@interface ColorWheelViewController ()

@property NSTimer* timer;
@property BOOL spinning;
@property BOOL transition;

@end

@implementation ColorWheelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorWheelTapped)];
    [self.view addGestureRecognizer:tapRecognizer];
   
    self.spinning=false;
    self.transition=false;
    self.timer = [NSTimer timerWithTimeInterval:1.0/60.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];

}

- (void)colorWheelTapped
{
    if (self.spinning) {
        self.transition=true;
    }
    else {
        self.spinning = true;
    }

}

- (void) update
{
    if (self.spinning && !self.transition) {
        ((ColorWheelView*) self.view).angle += 3.14159/60.0;
        [self.view setNeedsDisplay];
    }
    else if (self.transition) {
        [self.timer invalidate];
        [self performSegueWithIdentifier:@"headlines" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
