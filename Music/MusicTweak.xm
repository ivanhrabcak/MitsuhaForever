#import "Tweak.h"

static MSHFConfig *config = NULL;
static bool const colorflow = [%c(CFWPrefsManager) class] && MSHookIvar<BOOL>([%c(CFWPrefsManager) sharedInstance], "_musicEnabled");

%group MitsuhaVisuals

%hook MusicArtworkComponentImageView

-(void)layoutSubviews{
    %orig;
    if ([config view] == NULL) return;

    NSString *musicString;

    if (@available(iOS 13.0, *))
        musicString =  @"MusicApplication.NowPlayingContentView";
    else 
        musicString = @"Music.NowPlayingContentView";

    UIView *me = (UIView *)self;

    if ([NSStringFromClass([me.superview class]) isEqualToString:musicString]) {
        if (config.colorMode != 2) {
            [self readjustWaveColor];
        }

        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

%new;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"] && config.colorMode != 2) {
        [self readjustWaveColor];
    }
}

%new;
-(void)readjustWaveColor{
    [config colorizeView:((MusicArtworkComponentImageView*)self).image];
}

%end

%hook MusicNowPlayingControlsViewController
%property (retain,nonatomic) MSHFView *mshfView;

-(void)viewDidLoad{
    %orig;

    if(colorflow) {
        self.view.subviews[3].clipsToBounds = 1;
        [config initializeViewWithFrame:CGRectMake(0, -150, self.view.frame.size.width, (self.view.frame.size.height / 2) - 100)];
        
        self.mshfView = [config view];
        [self.view.subviews[3] addSubview:[config view]];
        [self.view.subviews[3] sendSubviewToBack:[config view]];

        if(self.mshfView.superview == NULL) {
            self.mshfView = [config view];
            [self.view addSubview:[config view]];
            [self.view sendSubviewToBack:[config view]];
        }
    } else {
        CGSize const screenSize = [[UIScreen mainScreen] bounds].size;

        self.view.clipsToBounds = 1;
        
        [config initializeViewWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        
        self.mshfView = [config view];
        [self.view addSubview:[config view]];
        [self.view sendSubviewToBack:[config view]];

        if (@available(iOS 14.0, *)) {
            return;
        }
        
        self.view.subviews[3].backgroundColor = [UIColor clearColor];
        self.view.subviews[4].backgroundColor = [UIColor clearColor];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    %orig;
    [[config view] start];
    if(colorflow) {
        [config view].center = CGPointMake([config view].center.x, 150);
    } else {
        [config view].center = CGPointMake([config view].center.x, [config view].frame.size.height);
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    %orig;
    [[config view] stop];
}

-(void)viewDidLayoutSubviews {
    %orig;
    if (@available(iOS 14.0, *)) {
        return;
    }
    if(!colorflow) {
        self.view.subviews[3].backgroundColor = [UIColor clearColor];
        self.view.subviews[4].backgroundColor = [UIColor clearColor];
    }
}

%end

%end

%ctor{
    config = [MSHFConfig loadConfigForApplication:@"Music"];
    config.waveOffsetOffset = 70;
    if(config.enabled){
        NSString *classString = nil;
        if(@available(iOS 13.0, *)) {
            classString = @"MusicApplication.ArtworkComponentImageView";
	    } else {
		    classString = @"Music.ArtworkComponentImageView";
        }
        
        %init(MitsuhaVisuals, MusicArtworkComponentImageView = NSClassFromString(classString));
    }
}