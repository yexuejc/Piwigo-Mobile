//
//  ReleaseNotesViewController.m
//  piwigo
//
//  Created by Eddy Lelièvre-Berna on 15/07/2017.
//  Copyright © 2017 Piwigo.org. All rights reserved.
//

#import "AppDelegate.h"
#import "ReleaseNotesViewController.h"
#import "Model.h"

@interface ReleaseNotesViewController ()

@property (nonatomic, strong) UILabel *piwigoTitle;
@property (nonatomic, strong) UILabel *byLabel1;
@property (nonatomic, strong) UILabel *byLabel2;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *releaseNotes;

@property (nonatomic, strong) UITextView *textView;

@end

@implementation ReleaseNotesViewController

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.title = NSLocalizedString(@"settings_releaseNotes", @"Release Notes");
        
        self.piwigoTitle = [UILabel new];
        self.piwigoTitle.translatesAutoresizingMaskIntoConstraints = NO;
        self.piwigoTitle.font = [UIFont piwigoFontLarge];
        self.piwigoTitle.textColor = [UIColor piwigoOrange];
        self.piwigoTitle.text = NSLocalizedString(@"settings_appName", @"Piwigo Mobile");
        [self.view addSubview:self.piwigoTitle];
        
        self.byLabel1 = [UILabel new];
        self.byLabel1.translatesAutoresizingMaskIntoConstraints = NO;
        self.byLabel1.font = [UIFont piwigoFontSmall];
        self.byLabel1.text = NSLocalizedStringFromTableInBundle(@"authors1", @"About", [NSBundle mainBundle], @"By Spencer Baker, Olaf Greck,");
        [self.view addSubview:self.byLabel1];
        
        self.byLabel2 = [UILabel new];
        self.byLabel2.translatesAutoresizingMaskIntoConstraints = NO;
        self.byLabel2.font = [UIFont piwigoFontSmall];
        self.byLabel2.text = NSLocalizedStringFromTableInBundle(@"authors2", @"About", [NSBundle mainBundle], @"and Eddy Lelièvre-Berna");
        [self.view addSubview:self.byLabel2];
        
        self.versionLabel = [UILabel new];
        self.versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.versionLabel.font = [UIFont piwigoFontTiny];
        [self.view addSubview:self.versionLabel];
        
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        self.versionLabel.text = [NSString stringWithFormat:@"— %@ %@ (%@) —", NSLocalizedString(@"Version:", nil), appVersionString, appBuildString];
        
        self.textView = [UITextView new];
        self.textView.restorationIdentifier = @"release+notes";
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Release notes attributed string
        NSMutableAttributedString *notesAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        NSMutableAttributedString *spacerAttributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\n\n"];
        NSRange spacerRange = NSMakeRange(0, [spacerAttributedString length]);
        [spacerAttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:spacerRange];

        // Release 2.2.0 — Bundle string
        NSString *v220String = NSLocalizedStringFromTableInBundle(@"v2.2.0_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.2.0 Release Notes text");
        NSMutableAttributedString *v220AttributedString = [[NSMutableAttributedString alloc] initWithString:v220String];
        NSRange v220Range = NSMakeRange(0, [v220String length]);
        [v220AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v220Range];
        v220Range = NSMakeRange(0, [v220String rangeOfString:@"\n"].location);
        [v220AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v220Range];
        [notesAttributedString appendAttributedString:v220AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.9 — Bundle string
        NSString *v219String = NSLocalizedStringFromTableInBundle(@"v2.1.9_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.9 Release Notes text");
        NSMutableAttributedString *v219AttributedString = [[NSMutableAttributedString alloc] initWithString:v219String];
        NSRange v219Range = NSMakeRange(0, [v219String length]);
        [v219AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v219Range];
        v219Range = NSMakeRange(0, [v219String rangeOfString:@"\n"].location);
        [v219AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v219Range];
        [notesAttributedString appendAttributedString:v219AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.8 — Bundle string
        NSString *v218String = NSLocalizedStringFromTableInBundle(@"v2.1.8_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.8 Release Notes text");
        NSMutableAttributedString *v218AttributedString = [[NSMutableAttributedString alloc] initWithString:v218String];
        NSRange v218Range = NSMakeRange(0, [v218String length]);
        [v218AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v218Range];
        v218Range = NSMakeRange(0, [v218String rangeOfString:@"\n"].location);
        [v218AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v218Range];
        [notesAttributedString appendAttributedString:v218AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.7 — Bundle string
        NSString *v217String = NSLocalizedStringFromTableInBundle(@"v2.1.7_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.7 Release Notes text");
        NSMutableAttributedString *v217AttributedString = [[NSMutableAttributedString alloc] initWithString:v217String];
        NSRange v217Range = NSMakeRange(0, [v217String length]);
        [v217AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v217Range];
        v217Range = NSMakeRange(0, [v217String rangeOfString:@"\n"].location);
        [v217AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v217Range];
        [notesAttributedString appendAttributedString:v217AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.6 — Bundle string
        NSString *v216String = NSLocalizedStringFromTableInBundle(@"v2.1.6_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.6 Release Notes text");
        NSMutableAttributedString *v216AttributedString = [[NSMutableAttributedString alloc] initWithString:v216String];
        NSRange v216Range = NSMakeRange(0, [v216String length]);
        [v216AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v216Range];
        v216Range = NSMakeRange(0, [v216String rangeOfString:@"\n"].location);
        [v216AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v216Range];
        [notesAttributedString appendAttributedString:v216AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.5 — Bundle string
        NSString *v215String = NSLocalizedStringFromTableInBundle(@"v2.1.5_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.5 Release Notes text");
        NSMutableAttributedString *v215AttributedString = [[NSMutableAttributedString alloc] initWithString:v215String];
        NSRange v215Range = NSMakeRange(0, [v215String length]);
        [v215AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v215Range];
        v215Range = NSMakeRange(0, [v215String rangeOfString:@"\n"].location);
        [v215AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v215Range];
        [notesAttributedString appendAttributedString:v215AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.4 — Bundle string
        NSString *v214String = NSLocalizedStringFromTableInBundle(@"v2.1.4_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.4 Release Notes text");
        NSMutableAttributedString *v214AttributedString = [[NSMutableAttributedString alloc] initWithString:v214String];
        NSRange v214Range = NSMakeRange(0, [v214String length]);
        [v214AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v214Range];
        v214Range = NSMakeRange(0, [v214String rangeOfString:@"\n"].location);
        [v214AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v214Range];
        [notesAttributedString appendAttributedString:v214AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.3 — Bundle string
        NSString *v213String = NSLocalizedStringFromTableInBundle(@"v2.1.3_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.3 Release Notes text");
        NSMutableAttributedString *v213AttributedString = [[NSMutableAttributedString alloc] initWithString:v213String];
        NSRange v213Range = NSMakeRange(0, [v213String length]);
        [v213AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v213Range];
        v213Range = NSMakeRange(0, [v213String rangeOfString:@"\n"].location);
        [v213AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v213Range];
        [notesAttributedString appendAttributedString:v213AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.2 — Bundle string
        NSString *v212String = NSLocalizedStringFromTableInBundle(@"v2.1.2_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.2 Release Notes text");
        NSMutableAttributedString *v212AttributedString = [[NSMutableAttributedString alloc] initWithString:v212String];
        NSRange v212Range = NSMakeRange(0, [v212String length]);
        [v212AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v212Range];
        v212Range = NSMakeRange(0, [v212String rangeOfString:@"\n"].location);
        [v212AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v212Range];
        [notesAttributedString appendAttributedString:v212AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.1 — Bundle string
        NSString *v211String = NSLocalizedStringFromTableInBundle(@"v2.1.1_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.1 Release Notes text");
        NSMutableAttributedString *v211AttributedString = [[NSMutableAttributedString alloc] initWithString:v211String];
        NSRange v211Range = NSMakeRange(0, [v211String length]);
        [v211AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v211Range];
        v211Range = NSMakeRange(0, [v211String rangeOfString:@"\n"].location);
        [v211AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v211Range];
        [notesAttributedString appendAttributedString:v211AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.1.0 — Bundle string
        NSString *v210String = NSLocalizedStringFromTableInBundle(@"v2.1.0_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.1.0 Release Notes text");
        NSMutableAttributedString *v210AttributedString = [[NSMutableAttributedString alloc] initWithString:v210String];
        NSRange v210Range = NSMakeRange(0, [v210String length]);
        [v210AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v210Range];
        v210Range = NSMakeRange(0, [v210String rangeOfString:@"\n"].location);
        [v210AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v210Range];
        [notesAttributedString appendAttributedString:v210AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.0.4 — Bundle string
        NSString *v204String = NSLocalizedStringFromTableInBundle(@"v2.0.4_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.0.4 Release Notes text");
        NSMutableAttributedString *v204AttributedString = [[NSMutableAttributedString alloc] initWithString:v204String];
        NSRange v204Range = NSMakeRange(0, [v204String length]);
        [v204AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v204Range];
        v204Range = NSMakeRange(0, [v204String rangeOfString:@"\n"].location);
        [v204AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v204Range];
        [notesAttributedString appendAttributedString:v204AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.0.3 — Bundle string
        NSString *v203String = NSLocalizedStringFromTableInBundle(@"v2.0.3_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.0.3 Release Notes text");
        NSMutableAttributedString *v203AttributedString = [[NSMutableAttributedString alloc] initWithString:v203String];
        NSRange v203Range = NSMakeRange(0, [v203String length]);
        [v203AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v203Range];
        v203Range = NSMakeRange(0, [v203String rangeOfString:@"\n"].location);
        [v203AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v203Range];
        [notesAttributedString appendAttributedString:v203AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.0.2 — Bundle string
        NSString *v202String = NSLocalizedStringFromTableInBundle(@"v2.0.2_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.0.2 Release Notes text");
        NSMutableAttributedString *v202AttributedString = [[NSMutableAttributedString alloc] initWithString:v202String];
        NSRange v202Range = NSMakeRange(0, [v202String length]);
        [v202AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v202Range];
        v202Range = NSMakeRange(0, [v202String rangeOfString:@"\n"].location);
        [v202AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v202Range];
        [notesAttributedString appendAttributedString:v202AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.0.1 — Bundle string
        NSString *v201String = NSLocalizedStringFromTableInBundle(@"v2.0.1_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.0.1 Release Notes text");
        NSMutableAttributedString *v201AttributedString = [[NSMutableAttributedString alloc] initWithString:v201String];
        NSRange v201Range = NSMakeRange(0, [v201String length]);
        [v201AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v201Range];
        v201Range = NSMakeRange(0, [v201String rangeOfString:@"\n"].location);
        [v201AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v201Range];
        [notesAttributedString appendAttributedString:v201AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 2.0.0 — Bundle string
        NSString *v200String = NSLocalizedStringFromTableInBundle(@"v2.0.0_text", @"ReleaseNotes", [NSBundle mainBundle], @"v2.0.0 Release Notes text");
        NSMutableAttributedString *v200AttributedString = [[NSMutableAttributedString alloc] initWithString:v200String];
        NSRange v200Range = NSMakeRange(0, [v200String length]);
        [v200AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v200Range];
        v200Range = NSMakeRange(0, [v200String rangeOfString:@"\n"].location);
        [v200AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v200Range];
        [notesAttributedString appendAttributedString:v200AttributedString];
        [notesAttributedString appendAttributedString:spacerAttributedString];

        // Release 1.0.0 — Bundle string
        NSString *v100String = NSLocalizedStringFromTableInBundle(@"v1.0.0_text", @"ReleaseNotes", [NSBundle mainBundle], @"v1.0.0 Release Notes text");
        NSMutableAttributedString *v100AttributedString = [[NSMutableAttributedString alloc] initWithString:v100String];
        NSRange v100Range = NSMakeRange(0, [v100String length]);
        [v100AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontSmall] range:v100Range];
        v100Range = NSMakeRange(0, [v100String rangeOfString:@"\n"].location);
        [v100AttributedString addAttribute:NSFontAttributeName value:[UIFont piwigoFontBold] range:v100Range];
        [notesAttributedString appendAttributedString:v100AttributedString];
        
        self.textView.attributedText = notesAttributedString;
        self.textView.editable = NO;
        self.textView.allowsEditingTextAttributes = NO;
        self.textView.selectable = YES;
        self.textView.scrollsToTop = YES;
        if (@available(iOS 11.0, *)) {
            self.textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        [self.view addSubview:self.textView];
        
        [self addConstraints];

        // Register palette changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged) name:kPiwigoNotificationPaletteChanged object:nil];
    }
    return self;
}

#pragma mark - View Lifecycle

-(void)paletteChanged
{
    // Background color of the view
    self.view.backgroundColor = [UIColor piwigoBackgroundColor];
    
    // Navigation bar appearence
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor piwigoWhiteCream],
                                 NSFontAttributeName: [UIFont piwigoFontNormal],
                                 };
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
    [self.navigationController.navigationBar setTintColor:[UIColor piwigoOrange]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor piwigoBackgroundColor]];
    self.navigationController.navigationBar.barStyle = [Model sharedInstance].isDarkPaletteActive ? UIBarStyleBlack : UIBarStyleDefault;
    
    // Text color depdending on background color
    self.byLabel1.textColor = [UIColor piwigoTextColor];
    self.byLabel2.textColor = [UIColor piwigoTextColor];
    self.versionLabel.textColor = [UIColor piwigoTextColor];
    self.textView.textColor = [UIColor piwigoTextColor];
    self.textView.backgroundColor = [UIColor piwigoBackgroundColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set colors, fonts, etc.
    [self paletteChanged];
}

-(void)addConstraints
{
    NSDictionary *views = @{
                            @"title" : self.piwigoTitle,
                            @"by1" : self.byLabel1,
                            @"by2" : self.byLabel2,
                            @"usu" : self.versionLabel,
                            @"textView" : self.textView
                            };
    
    [self.view addConstraint:[NSLayoutConstraint constraintCenterVerticalView:self.piwigoTitle]];
    [self.view addConstraint:[NSLayoutConstraint constraintCenterVerticalView:self.byLabel1]];
    [self.view addConstraint:[NSLayoutConstraint constraintCenterVerticalView:self.byLabel2]];
    [self.view addConstraint:[NSLayoutConstraint constraintCenterVerticalView:self.versionLabel]];
    
    if (@available(iOS 11, *)) {
        [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-[title][by1][by2]-3-[usu]-10-[textView]-|"
                               options:kNilOptions metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[textView]-|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-80-[title][by1][by2]-3-[usu]-10-[textView]-|"
                                   options:kNilOptions metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[textView]-15-|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
    }

}

@end
