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
    P2MSAnimationObject *fishObj;
    
    P2MSStoryboard *storyboard;
    UIImageView *footer;
    UIButton *prevBtn, *nextBtn;
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


//#define SHOW_STORYBOOK 1

- (void)viewDidLoad
{
    [super viewDidLoad];
  
//#ifdef SHOW_STORYBOOK
    if ([UIImage imageNamed:@"pg01_text.png"] && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyboard = [[P2MSStoryboard alloc]initWithFrame:self.view.bounds];
        storyboard.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ExampleStory" ofType:@"txt"];
        [self.view addSubview:storyboard];
        [storyboard loadScenesFromFilePath:filePath];
        storyboard.delegate = self;
        [storyboard startReading];
        
        footer = [[UIImageView alloc]initWithFrame:CGRectMake(0, 688, 1024, 80)];
        [footer setImage:[UIImage imageNamed:@"footer"]];
        footer.userInteractionEnabled = YES;
        [self.view addSubview:footer];
        footer.hidden = YES;
        
        prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [prevBtn setImage:[UIImage imageNamed:@"button_left"] forState:UIControlStateNormal];
        prevBtn.frame = CGRectMake(800, 10, 56, 63);
        [prevBtn addTarget:self action:@selector(prevScene:) forControlEvents:UIControlEventTouchUpInside];
        [footer addSubview:prevBtn];
        
        nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextBtn setImage:[UIImage imageNamed:@"button_right"] forState:UIControlStateNormal];
        nextBtn.frame = CGRectMake(900, 10, 56, 63);
        [nextBtn addTarget:self action:@selector(nextScene:) forControlEvents:UIControlEventTouchUpInside];
        [footer addSubview:nextBtn];
//#else
    }else{
        //viewDidLoad is usually call in Portrait mode and need to wait until the rotation is completed
        //please adjust the delay accordingly
        [self performSelector:@selector(loadObjects) withObject:nil afterDelay:0.01f];
        
    }
//#endif

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

    //the references (performP2MSSelector & P2MSObjectBehavior) made in the P2MSAnimationObject are weak and it is required to retain the object until all the animation is done
    fishObj = [[P2MSAnimationObject alloc]init];
    P2MSAnimation *anim = [P2MSAnimation animationString:@"s_move:1,7,80%,175|s_replace:0,0,fish.png|s_flip_rotate:1,0,-1,1,-30|s_move:0,10,5%,100|s_reset_transform:0.1,0" repeatCount:2 serialIndex:0];
//    P2MSAnimation *animation = [P2MSAnimation animationWithChildAnimations:[NSArray arrayWithObjects:anim, nil] repeatCount:1 serialStartIndex:1];
    [fishObj loadObject:nil withAnimation:anim associatedParentView:self.view withTag:5 initialParams:@"fish_3.png##fish_2.png##fish_1.png 20,170,59,52 1 1,0"];
    fishObj.delegate = self;
    [fishObj startTask];

}

- (void)animationDone:(P2MSAnimationObject *)animatedObject{
    if ([animatedObject isEqual:fishObj]) {
        [fishObj removeObject:YES];
        fishObj = nil;
    }
}

- (IBAction)nextScene:(id)sender{
    [storyboard nextScene];
    nextBtn.enabled = (storyboard.curSceneIndex < storyboard.totalScenes-1);
    prevBtn.enabled = (storyboard.curSceneIndex > 0);
}

- (IBAction)prevScene:(id)sender{
    [storyboard previousScene];
    nextBtn.enabled = (storyboard.curSceneIndex < storyboard.totalScenes-1);
    prevBtn.enabled = (storyboard.curSceneIndex > 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickedObject:(id<P2MSAbstractObject>)object forSceneIndex:(NSInteger)sceneIndex{
    if (sceneIndex == 1 && object.objectTag == 2) {
        [self nextScene:nil];
    }
}

- (void)changedToScene:(NSInteger)sceneIndex{
    footer.hidden = sceneIndex <= 1;
}

- (void)draggedObject:(id<P2MSAbstractObject>)object at:(CGPoint)curPosition withGestureRecognizer:(UIGestureRecognizer *)gesture forSceneIndex:(NSInteger)sceneIndex{
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (sceneIndex == 2 && object.objectTag == 4) {
            if (CGRectIntersectsRect(CGRectMake(370, 421, 119, 55), object.view.frame)) {
                [UIView animateWithDuration:0.25 animations:^{
                    object.view.center = CGPointMake(428, 435);
                }];
            }else{
                [UIView animateWithDuration:0.5 animations:^{
                    object.view.center = CGPointMake(object.view.center.x, self.view.bounds.size.height-120);
                }];
            }
        }
    }
}

@end
