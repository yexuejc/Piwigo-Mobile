//
//  EditImageTextFieldTableViewCell.m
//  piwigo
//
//  Created by Spencer Baker on 2/8/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import "EditImageTextFieldTableViewCell.h"
#import "Model.h"

@interface EditImageTextFieldTableViewCell()

@property (nonatomic, strong) NSString *textString;

@end

@implementation EditImageTextFieldTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.cellLabel.font = [UIFont piwigoFontNormal];
    self.cellTextField.font = [UIFont piwigoFontNormal];
    self.cellTextField.keyboardType = UIKeyboardTypeDefault;
    self.cellTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.cellTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    self.cellTextField.returnKeyType = UIReturnKeyDefault;
    self.cellTextField.clearButtonMode = UITextFieldViewModeAlways;
}

-(void)setTextString:(NSString *)textString
{
    self.textString = textString;

    if (textString.length <= 0)
    {
        self.cellTextField.text = @"";
    }
    else
    {
        self.cellTextField.text = textString;
    }

    self.cellLabel.textColor = [UIColor piwigoLeftLabelColor];
    self.cellTextField.textColor = [UIColor piwigoLeftLabelColor];
    self.cellTextField.backgroundColor = [UIColor piwigoBackgroundColor];
    if ([[self.cellTextField.attributedPlaceholder string] length] > 0) {
        NSString *placeHolder = [self.cellTextField.attributedPlaceholder string];
        self.cellTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{NSForegroundColorAttributeName: [UIColor piwigoRightLabelColor]}];
    }
    self.cellTextField.keyboardAppearance = [Model sharedInstance].isDarkPaletteActive ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
}

-(void)prepareForReuse
{
    [super prepareForReuse];

    self.cellTextField.delegate = nil;
    self.cellTextField.text = @"";
}


@end
