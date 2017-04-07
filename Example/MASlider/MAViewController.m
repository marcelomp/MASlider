//
//  MAViewController.m
//  MASlider
//
//  Created by mpmarcelomp@gmail.com on 04/07/2017.
//  Copyright (c) 2017 mpmarcelomp@gmail.com. All rights reserved.
//

#import "MAViewController.h"

#import "MASlider.h"

@interface MAViewController () <MASliderDataSource>

@property (weak, nonatomic) IBOutlet MASlider *slider;

@end

@implementation MAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.slider.dataSource = self;
    [self.slider addTarget:self action:@selector(handleValueChange:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleValueChange:(MASlider *)slider {
    NSLog(@"slider.step=%ld", slider.step);
}

#pragma mark - MASliderDataSource

- (NSAttributedString *)slider:(MASlider *)slider titleForIndex:(NSInteger)index {
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"teste teste %ld", index]];
    [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attribString.length)];
    [attribString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, attribString.length)];
    
    if (index == slider.step) {
        [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attribString.length)];
        [attribString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attribString.length)];
    }
    
    return attribString;
}

@end
