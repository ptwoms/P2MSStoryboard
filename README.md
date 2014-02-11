P2MSStoryboard (OnGoing)
==============

This libray is not meant for creating game or complex animations. It provides a quick and easy way for creating animated simple objects in uiview with few lines of codes. It is also intended to create animation scenes with least coding.

***The project concept is in experimental stage and requires improvements.***

It works on IOS 4.3+


##Usage
###P2MSObject
    P2MSObject *object = [[P2MSObject alloc]init];
    object loadObject:@"Animation String" inView:canvasView withTag:imgTag];
    
    //eg
    [object loadObject:@"default pluto_1.png|pluto_2.png|pluto_3.png|pluto_4.png|pluto_5.png|pluto_6.png|pluto_7.png|pluto_8.png 95,49 10%,50% 1,1,0 move:0.1,9,70%,50%|animate:0,0,pluto_2_1##pluto_2_2##pluto_2_3,1,0,75%" inView:self.view withTag:1];

###P2MSAnimationObject
    P2MSAnimationObject *fishObj;
    //////////////////////////////////////////////////////
    //the references (performP2MSSelector & P2MSObjectBehavior) made in the P2MSAnimationObject are weak and it is required to retain the object in ARC environment until all the animation is done
    //////////////////////////////////////////////////////
    
	fishObj = [[P2MSAnimationObject alloc]init];
	
	//create animation object
    P2MSAnimation *anim = [P2MSAnimation animationString:@"s_move:1,7,80%,175|s_replace:0,0,fish.png|s_flip_rotate:1,0,-1,1,-30|s_move:0,10,5%,100|s_reset_transform:0.1,0" repeatCount:1 serialIndex:0];
    P2MSAnimation *animation = [P2MSAnimation animationWithChildAnimations:[NSArray arrayWithObjects:anim, nil] repeatCount:1 serialStartIndex:1];
    
    //create fishObj view
    [fishObj loadObject:nil withAnimation:animation associatedParentView:self.view withTag:5 initialParams:@"fish_3.png##fish_2.png##fish_1.png 20,170,59,52 1 1,0"];
    fishObj.delegate = self;
    
    //start animation
    [fishObj startTask];

###P2MSStoryboard

	P2MSStoryboard *storyboard;
	
    storyboard = [[P2MSStoryboard alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:storyboard];
    
    //load the scene control file
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ExampleStory" ofType:@"txt"];
    [storyboard loadScenesFromFilePath:filePath];
    storyboard.delegate = self;

    [storyboard startReading];

You can create your own custom objects and animation behaviors by implementing ***P2MSAbstractObject*** and ***P2MSObjectBehavior*** protocols or can extend the default implemetations (***P2MSDefaultObject*** and ***P2MSStandardBehavior***).

I will update the [wiki](https://github.com/ptwoms/P2MSStoryboard/wiki) later.


##Credits
* <big>Sprite Images - <a href="https://archive.org/details/ug-sprite-sheet-collection-v2">Link</a></big>
* <big>Tammy Coron - *How to Create an Interactive Children’s Book for the iPad* [Link](http://www.raywenderlich.com/56858/how-to-create-an-interactive-childrens-book-for-the-ipad)</big>


###Contributions
- <big>Contributions and suggestions are welcome</big>
