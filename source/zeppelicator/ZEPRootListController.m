#include "ZEPRootListController.h"
#import <CoreGraphics/CoreGraphics.h>

UIImage *icon = nil;
UITextField *iconNameField;
    
@implementation UIImage (scale)
-(UIImage *)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
  
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
 
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
 
    UIGraphicsEndImageContext();

    return scaledImage;
}
@end
    
@implementation ZEPRootListController
- (NSArray *)specifiers
{
	if (!_specifiers)
    {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)createIcon
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([icon isEqual:nil])
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }
    else
    {
        icon = [info objectForKey:UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Zeppelicator" message: @"Name icon" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
        {
            textField.placeholder = @"Name";
            textField.textColor = [UIColor blueColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            NSArray *textfields = alertController.textFields;
            UITextField *namefield = textfields[0];
            NSString *path = @"/Library/Zeppelin/";
            path = [path stringByAppendingString:namefield.text];
            BOOL isDir = NO;
            if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir])
            {
                [[[UIAlertView alloc] initWithTitle:namefield.text message:@"An icon with that name already exists." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            }
            else
            {
                const char *cmd = (const char *)[[@"mkdir " stringByAppendingString:path] UTF8String];
                system(cmd);
                icon = [icon scaleToSize:CGSizeMake(icon.size.width / (icon.size.height/40), icon.size.height / (icon.size.height / 40))];
                [UIImagePNGRepresentation(icon) writeToFile:[path stringByAppendingString:@"/black@2x.png"] atomically:YES];
                [UIImagePNGRepresentation(icon) writeToFile:[path stringByAppendingString:@"/etched@2x.png"] atomically:YES];
                [UIImagePNGRepresentation(icon) writeToFile:[path stringByAppendingString:@"/silver@2x.png"] atomically:YES];
                [[[UIAlertView alloc] initWithTitle:namefield.text message:@"Icon created. To enable it, select it from the list of themes in Zeppelin settings." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
@end