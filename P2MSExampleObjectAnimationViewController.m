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
    BOOL isStoryBook;
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
    
    storyboard = [[P2MSStoryboard alloc]initWithFrame:self.view.bounds];
    storyboard.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:storyboard];
  
    //This is the storyboard version of the work of Tammy Coron from www.raywenderlich.com. (http://www.raywenderlich.com/56858/how-to-create-an-interactive-childrens-book-for-the-ipad)
    //It is required to import her artwork files to the project in order to run this example.
    //http://cdn4.raywenderlich.com/downloads/TheSeasons_Finished.zip
    
    footer = [[UIImageView alloc]initWithFrame:CGRectMake(0, 688, 1024, 80)];
    footer.userInteractionEnabled = YES;
    
    prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    prevBtn.frame = CGRectMake(800, 10, 56, 63);
    [prevBtn addTarget:self action:@selector(prevScene:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:prevBtn];
    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(900, 10, 56, 63);
    [nextBtn addTarget:self action:@selector(nextScene:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:nextBtn];

    
    if ([UIImage imageNamed:@"pg01_text.png"] && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        footer.hidden = YES;
        isStoryBook = YES;
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ExampleStory" ofType:@"txt"];
        storyboard.delegate = self;
        [storyboard loadScenesFromFilePath:filePath];
        [storyboard startReading];
        [footer setImage:[UIImage imageNamed:@"footer"]];
        [prevBtn setImage:[UIImage imageNamed:@"button_left"] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"button_right"] forState:UIControlStateNormal];
    }else{
        //order of exection is important since allRemoteImageLoaded() will call immediately if all images are loaded
        UILabel *label = [[UILabel alloc]initWithFrame:self.view.bounds];
        label.font = [UIFont boldSystemFontOfSize:30];
        label.textColor = [UIColor colorWithRed:90.0f/255.0f green:157.0f/255.0f blue:125.0f/255.0f alpha:0.9];
        label.text = @"Loading Images. Please wait...";
        label.textAlignment = UITextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.tag = 121;
        [self.view addSubview:label];

        //Load remote images
        NSString *filePathRemote = [[NSBundle mainBundle]pathForResource:@"StoryWithRemoteImage" ofType:@"txt"];
        [storyboard loadScenesFromFilePath:filePathRemote];
        storyboard.delegate = self;
        [storyboard preloadRemoteImagesForScenes];
        [footer setBackgroundColor:[UIColor lightGrayColor]];
        [prevBtn setImage:[UIImage imageNamed:@"draft_button_left"] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"draft_button_right"] forState:UIControlStateNormal];
        isStoryBook = NO;
    }
    
//viewDidLoad is usually call in Portrait mode and need to wait until the rotation is completed
//        [self performSelector:@selector(loadObjects) withObject:nil afterDelay:0.01f];
    [self.view addSubview:footer];

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
    P2MSAnimation *anim = [P2MSAnimation animationString:@"s_move:1,7,80%,175|replace:0,fish.png|s_flip_rotate:1,0,-1,1,-30|s_move:0,10,5%,100|reset_transform:0.1" repeatCount:2 serialIndex:0];
    [fishObj loadObject:nil withAnimation:anim associatedParentView:self.view withTag:5 initialParams:@"fish_3.png##fish_2.png##fish_1.png 20,170,59,52 1 1,0"];
    fishObj.delegate = self;
    [fishObj startTask];
    
    //    P2MSAnimation *animation = [P2MSAnimation animationWithChildAnimations:[NSArray arrayWithObjects:anim, nil] repeatCount:1 serialStartIndex:1];
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
    if (isStoryBook) {
        footer.hidden = (sceneIndex <= 1);
    }
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

- (void)allRemoteImageLoaded:(P2MSStoryboard *)storyboardObj{
    [[self.view viewWithTag:121]removeFromSuperview];
    [storyboardObj startReading];
}

- (void)remoteImageLoadFailed:(NSString *)imageURL{
    //do something for unloaded images
}



@end
