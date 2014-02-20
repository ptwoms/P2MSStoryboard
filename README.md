P2MSStoryboard (Development)
==============

This libray is not meant for creating game or complex animations. It provides a quick and easy way for creating animated simple objects in uiview with few lines of codes. It is also intended to create animation scenes with least coding.

Supported platform: IOS 5.0+



###P2MSAnimationObject
####Usage
    P2MSAnimationObject *fishObj;
    //////////////////////////////////////////////////////
    //the references (performP2MSSelector & P2MSObjectBehavior) made in the P2MSAnimationObject are weak and it is required to retain the object in ARC environment until all the animation is done
    //////////////////////////////////////////////////////
    
	fishObj = [[P2MSAnimationObject alloc]init];
	
	//create animation object
    P2MSAnimation *animation = [P2MSAnimation animationString:@"s_move:1,7,80%,175|replace:0,0,fish.png|s_flip_rotate:1,0,-1,1,-30|s_move:0,10,5%,100|reset_transform:0.1,0" repeatCount:1 serialIndex:0];
    
    //create fishObj view
    [fishObj loadObject:nil withAnimation:animation associatedParentView:self.view withTag:5 initialParams:@"fish_3.png##fish_2.png##fish_1.png 20,170,59,52 1 1,0"];
    fishObj.delegate = self;
    
    //start animation
    [fishObj startTask];

<i>It is required to implement <b>P2MSAbstractObject</b> or extends <b>P2MSDefaultObject</b> (which has default implementations for processing animations) to create new custom objects.</i>

####Animations
<pre>
<b>s_move         </b>:delay_time,animation_period,toX,toY
<b>s_move_scale   </b>:delay_time,animation_period,toX,toY,newWidth,newHeight
<b>s_alpha        </b>:delay_time,animation_period,to_alpha_value
<b>s_rotate       </b>:delay_time,animation_period,to_degree
<b>s_clock_rotate </b>:delay_time,animation_period,num_of_rotation
<b>s_flip_rotate  </b>:delay_time,animation_period,scaleX,scaleY,to_degree
<b>reset_transform</b>:delay_time
<b>replace        </b>:delay_time,image_name,(newX),(newY),(newWidth),(newHeight)
<b>animate        </b>:delay_time,animation_duration,animation_repeat_count,images_sep_by_##
<b>depend         </b>:delay_time,obj_tag_to_wait,obj_animation_index,animation_sub_index, repeat_count

<i>implements <b>P2MSObjectBehavior</b> protocol (or extends <b>P2MSStandardBehavior</b> to create new custom animations.</i>
</pre>
####Animation string

*Serial execution* <small>(Separated by '|' character)</small>

	anim_string|anim_string|anim_string

*Serial+Parallel execution* <small>(Separated by '--' character)</small>

	anim_string|anim_string--anim_string

(*[P2MSAnimation animationString:@"anim_string" repeatCount:repeatCount serialIndex:animationObjectIndex];*)

####Animation Representation

*animation with repeat count*

	animation_rep => [animation_string;repeat_count]
	
*animation with repeat count and two children*

	animation_rep => [[child1_animation_string;child1_repeat_count];	[child2_animation_string,child2_repeat_count];parent_animation_repeat_count]

(***[P2MSAnimation animationFromString:@"animation_rep"];***)


Please see the [wiki](https://github.com/ptwoms/P2MSStoryboard/wiki/P2MSAnimationObject) for more information

###P2MSStoryboard
####Usage

	P2MSStoryboard *storyboard;
	
    storyboard = [[P2MSStoryboard alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:storyboard];
    
    //load the scene control file
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ExampleStory" ofType:@"txt"];
    [storyboard loadScenesFromFilePath:filePath];
    storyboard.delegate = self;

    [storyboard startReading];
    
It is required to preload the images if the scenes file contains images from remote URL.
<pre>[storyboard preloadRemoteImagesForScenes];</pre>
In this case, call the "***[storyboard startReading];***" from *allRemoteImageLoaded* delegate method.

####Scenes file format
<pre>
scene_1_background_image
#
scene_1_object representation 1
#
scene_1_object representation 2
##
scene_2_background_image
#
scene_2_object representation 1
#
scene_2_object representation 2
..
//it is required to have "http://" or "https://" in if the image is URL
</pre>
<sup>*background and objects are separated by \n#\n and scenes are separated by \n##\n*</sup>

**Image Object Representation**
<pre>
object object_image initial_Rect init_alpha,init_additional_params animation_represtation
</pre>

**Text Object Representation**
<pre>
text #1 initial_Rect init_alpha animation_representation
###
string for #1
</pre>

##Credits
* <big>Sprite Images - <a href="https://archive.org/details/ug-sprite-sheet-collection-v2">Link</a></big>
* <big>Tammy Coron - *How to Create an Interactive Children’s Book for the iPad* [Link](http://www.raywenderlich.com/56858/how-to-create-an-interactive-childrens-book-for-the-ipad)</big>
* <big>Wallpaper Images [Link](http://www.utepprintstore.com/)</big>


###Contributions
- <big>Contributions and Suggestions are welcome.</big>
- <big>Please open issues for suggestions.</big>
