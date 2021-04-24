//
//  UnityNative_Sharing.mm
//
//  Created by Nicholas Sheehan on 01/06/2018.
//

#import "UnityNative_Sharing.h"

//
// Shares Text
//
void UnityNative_Sharing_ShareText(const char* shareText)
{
    UnityNative_Sharing_ShareTextAndFile(shareText, "");
}

//
// Shares File and Text
//
void UnityNative_Sharing_ShareTextAndFile(const char* shareText, const char* filePath)
{
    NSMutableArray *items = [NSMutableArray new];
    
    NSString *textToShare = [NSString stringWithUTF8String:shareText];
    if(textToShare != NULL && textToShare.length > 0)
    {
        [items addObject:textToShare];
    }
    
    NSString *pathToFile = [NSString stringWithUTF8String:filePath];
    if(pathToFile != NULL && pathToFile.length > 0)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Check to see if the file exists
        if([fileManager fileExistsAtPath:pathToFile])
        {
            NSURL *formattedURL = [NSURL fileURLWithPath:pathToFile];
            [items addObject:formattedURL];
        }
        // File not found
        else
        {
            NSString *message = [NSString stringWithFormat:@"Cannot find file %@", pathToFile];
            NSLog(@"%s", message.UTF8String);
        }
    }
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                           applicationActivities:nil];
    
//    [activity setValue:@"" forKey:@"subject"]; // TODO be able to set a subject string here
    
    // Callback from iOS when the activity finishes
    activity.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
    {
        NSLog(@"Shared to %s", activityType.UTF8String);
        
        if(activityError)
        {
            NSLog(@"Error: [%@]", activityError);
        }
        
        // TODO maybe a callback into Unity here?
    };
    
    UIViewController *rootViewController = UnityGetGLViewController();
    
    CGSize screenSize = rootViewController.view.frame.size;
    
    // TODO make this confirgureable from C#
    CGRect rect = CGRectMake(screenSize.width / 2,  // Width
                             screenSize.height / 4, // Height
                             0,                     // X
                             0);                    // Y
    
    activity.modalPresentationStyle = UIModalPresentationPopover;
    [rootViewController presentViewController:activity
                                     animated:YES
                                   completion:nil]; // Completion is invoked when the popup finishes animating in
    
    UIPopoverPresentationController *popup = activity.popoverPresentationController;
    popup.sourceView = rootViewController.view;
    popup.sourceRect = rect;
    popup.permittedArrowDirections = UIPopoverArrowDirectionAny;
}
