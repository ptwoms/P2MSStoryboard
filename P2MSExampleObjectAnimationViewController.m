//
//  P2MSExampleObjectAnimationViewController.m
//  P2MSStoryboard
//
//  Created by PYAE PHYO MYINT SOE on 21/12/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSExampleObjectAnimationViewController.h"
#import "P2MSObject.h"

@interface P2MSExampleObjectAnimationViewController (){
//    P2MSObject *object;
}

@end

@implementation P2MSExampleObjectAnimationViewController

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

    //viewDidLoad is usually call in Portrait mode and need to wait until the rotation is completed
    //please adjust the delay accordingly
    [self performSelector:@selector(loadObjects) withObject:nil afterDelay:0.01f];
}

- (void)loadObjects{
    P2MSObject *object = [[P2MSObject alloc]init];
    [object loadObject:@"default pluto_1.png##pluto_2.png##pluto_3.png##pluto_4.png##pluto_5.png##pluto_6.png##pluto_7.png##pluto_8.png 95,49 10%,50% 1,1,0 move:0.1,7,70%,50%|animate:0,0,pluto_2_1##pluto_2_2##pluto_2_3,1,0,75%,,," inView:self.view withTag:1];
    
    P2MSObject *clockBase = [[P2MSObject alloc]init];
    [clockBase loadObject:@"default clock_base.png 109,109 100,20 0 alpha:1,0.5,1.0" inView:self.view withTag:2];
    
    P2MSObject *hour = [[P2MSObject alloc]init];
    [hour loadObject:@"default hour.png 4,76 153,37 0,0,0 alpha:1,0.5,1.0|clock_rotate:0,120,0" inView:self.view withTag:3];
    
    P2MSObject *minute = [[P2MSObject alloc]init];
    [minute loadObject:@"default minute.png 3,93 153,28 0,0,0 alpha:1,0.5,1.0|clock_rotate:0,10,0" inView:self.view withTag:4];
    
    P2MSObject *fishObj = [[P2MSObject alloc]init];
    [fishObj loadObject:@"default fish_3.png##fish_2.png##fish_1.png 59,52 10%,170 1,1,0 move:1,7,80%,175|replace:0,0,fish.png|flip_rotate:1,0,-1,1,-30|move:0,10,5%,100|reset_transform:0.1,0" inView:self.view withTag:5];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
