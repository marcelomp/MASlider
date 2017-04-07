//
//  MASlider.m
//  Pods
//
//  Created by Marcelo Mendes on 07/04/17.
//
//

#import "MASlider.h"

static CGFloat const kAnimationSpeed    = 0.15;
static CGFloat const kThumbSize         = 44;
static CGFloat const kKnotSize          = 16;
static CGFloat const kTrackWidth        = 4;

typedef struct StepCenterPair {
    NSInteger index;
    CGPoint center;
} StepCenterPair;

@interface MASlider ()

@property (strong, nonatomic) CAShapeLayer *trackLayer;
@property (strong, nonatomic) CALayer *knotsLayer;
@property (strong, nonatomic) NSArray<CAShapeLayer *> *knots;
@property (strong, nonatomic) UIButton *thumb;
@property (strong, nonatomic) NSArray<UILabel *> *valueLabels;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation MASlider

@synthesize trackTintColor = _trackTintColor;
@synthesize thumbTintColor = _thumbTintColor;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) { return nil; }
    
    [self initProperties];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    
    [self initProperties];
    
    return self;
}

- (void)setStep:(NSUInteger)step animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:kAnimationSpeed delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.step = step;
        } completion:nil];
        
    } else {
        self.step = step;
    }
}

- (void)setStep:(NSUInteger)step {
    _step = step > (self.numberOfSteps - 1) ? (self.numberOfSteps - 1) : step;
    [self updateThumbWithSelectedStep:_step];
    [self updateValueLabels];
}

- (void)setNumberOfSteps:(NSUInteger)numberOfSteps {
    _numberOfSteps = MAX(2, numberOfSteps);
    [self updateKnots];
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    self.trackLayer.fillColor = _trackTintColor.CGColor;
    [self updateKnotsColor];
    [self setNeedsDisplay];
}

- (UIColor *)trackTintColor {
    _trackTintColor = _trackTintColor ?: UIColor.lightGrayColor;
    return _trackTintColor;
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    _thumbTintColor = thumbTintColor;
    self.thumb.backgroundColor = self.thumbTintColor;
    [self setNeedsDisplay];
}

- (UIColor *)thumbTintColor {
    _thumbTintColor = _thumbTintColor ?: UIColor.lightGrayColor;
    return _thumbTintColor;
}

- (void)setThumbImage:(UIImage *)thumbImage {
    _thumbImage = [thumbImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.thumb setImage:_thumbImage forState:UIControlStateNormal];
    [self.thumb setImage:_thumbImage forState:UIControlStateSelected];
    [self.thumb setImage:_thumbImage forState:UIControlStateHighlighted];
    self.thumb.tintColor = UIColor.whiteColor;
    [self setNeedsDisplay];
}

- (void)setStepText:(NSString *)stepText {
    _stepText = stepText.length > 0 ? stepText : @"";
    [self updateValueLabels];
    [self setNeedsDisplay];
}

- (void)setAttributedStepText:(NSAttributedString *)attributedStepText {
    _attributedStepText = attributedStepText.length > 0 ? attributedStepText : [[NSAttributedString alloc] initWithString:@""];
    [self updateValueLabels];
    [self setNeedsDisplay];
}

- (void)setSelectedStepText:(NSString *)selectedStepText {
    _selectedStepText = selectedStepText.length > 0 ? selectedStepText : @"";
    [self updateValueLabels];
    [self setNeedsDisplay];
}

- (void)setAttributedSelectedStepText:(NSAttributedString *)attributedSelectedStepText {
    _attributedSelectedStepText = attributedSelectedStepText.length > 0 ? attributedSelectedStepText : [[NSAttributedString alloc] initWithString:@""];
    [self updateValueLabels];
    [self setNeedsDisplay];
}

- (void)initProperties {
    
    self.trackLayer = [CAShapeLayer layer];
    self.trackLayer.path = [self trackBezierPath].CGPath;
    self.trackLayer.fillColor = self.trackTintColor.CGColor;
    [self.layer addSublayer:self.trackLayer];
    
    self.knotsLayer = [CALayer layer];
    [self.layer addSublayer:self.knotsLayer];
    self.knots = @[];
    
    self.thumb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kThumbSize, kThumbSize)];
    self.thumb.center = CGPointMake(kThumbSize/2, [self rectForSlider].size.height/2);
    self.thumb.layer.cornerRadius = self.thumb.frame.size.height/2;
    self.thumb.backgroundColor = self.thumbTintColor;
    [self addSubview:self.thumb];
    
    self.valueLabels = @[];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.cancelsTouchesInView = NO;
    [self.thumb addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.thumb addGestureRecognizer:self.tapGestureRecognizer];
}

- (CGRect)trackRect {
    return CGRectMake(kThumbSize/2, [self rectForSlider].size.height/2 - kTrackWidth/2, [self rectForSlider].size.width - kThumbSize, kTrackWidth);
}

- (UIBezierPath *)trackBezierPath {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:[self trackRect]];
    return path;
}

- (CGRect)rectForSlider {
    return CGRectMake(0, 0, self.bounds.size.width, kThumbSize);
}

- (CGRect)rectForLabels {
    return CGRectMake(0, kThumbSize, self.bounds.size.width, self.bounds.size.height - kThumbSize);
}

- (CGPoint)centerPositionForIndex:(NSInteger)index {
    
    CGFloat xPos = [self trackRect].size.width/(self.numberOfSteps-1)*index + kThumbSize/2;
    CGFloat yPos = [self rectForSlider].size.height/2;
    
    if (index == 0) {
        xPos = kThumbSize/2;
        
    } else if (index == self.numberOfSteps - 1) {
        xPos = [self rectForSlider].size.width - kThumbSize/2;
    }
    
    return CGPointMake(xPos, yPos);
}

- (CAShapeLayer *)knotForIndex:(NSInteger)index {
    CAShapeLayer *layer = [CAShapeLayer layer];
    CGPoint center = [self centerPositionForIndex:index];
    CGRect rect = CGRectMake(center.x - kKnotSize/2, center.y - kKnotSize/2, kKnotSize, kKnotSize);
    layer.path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kKnotSize/2].CGPath;
    layer.fillColor = self.trackTintColor.CGColor;
    return layer;
}

- (void)updateKnotsLayer {
    self.knotsLayer.frame = [self rectForSlider];
}

- (void)updateKnotsColor {
    for (CAShapeLayer *knot in self.knots) {
        knot.fillColor = self.trackTintColor.CGColor;
    }
}

- (void)updateKnots {
    
    for (CAShapeLayer *layer in self.knots) {
        [layer removeFromSuperlayer];
    }
    
    NSMutableArray<CAShapeLayer *> *knots = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < self.numberOfSteps; ++i) {
        CAShapeLayer *layer = [self knotForIndex:i];
        [self.knotsLayer addSublayer:layer];
        [knots addObject:layer];
    }
    
    self.knots = knots;
    [self setNeedsDisplay];
}

- (void)updateTrack {
    self.trackLayer.path = [self trackBezierPath].CGPath;
    [self setNeedsDisplay];
}

- (void)updateThumbWithSelectedStep:(NSInteger)step {
    CGPoint pos = [self centerPositionForIndex:step];
    self.thumb.center = pos;
    [self setNeedsDisplay];
}

- (UILabel *)valueLabelForIndex:(NSInteger)index selected:(BOOL)selected {
    CGRect labelsRect = [self rectForLabels];
    CGFloat xPos = labelsRect.size.width/self.numberOfSteps * index;
    CGPoint center = [self centerPositionForIndex:index];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPos, labelsRect.origin.y, 64, labelsRect.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.font = [UIFont systemFontOfSize:11];
    label.text = self.stepText;
    label.textColor = [UIColor lightGrayColor];
    
    if (self.attributedStepText.length > 0) {
        label.attributedText = self.attributedStepText;
    }
    
    if (selected) {
        label.font = [UIFont boldSystemFontOfSize:13];
        label.text = self.selectedStepText;
        label.textColor = UIColor.blackColor;
        if (self.attributedSelectedStepText.length > 0) {
            label.attributedText = self.attributedSelectedStepText;
        }
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(slider:titleForIndex:)]) {
        
        NSAttributedString *attribString = [self.dataSource slider:self titleForIndex:index];
        
        if (attribString.length > 0) {
            label.attributedText = attribString;
        }
    }
    
    [label sizeToFit];
    
    CGRect frame = label.frame;
    CGFloat xCenter = center.x;
    
    if (xCenter - frame.size.width/2 < 0) { xCenter = frame.size.width/2; }
    else if (xCenter + frame.size.width/2 > labelsRect.size.width) { xCenter = labelsRect.size.width - frame.size.width/2; }
    
    label.center = CGPointMake(xCenter, label.center.y + 8);
    [self addSubview:label];
    
    return label;
}

- (void)updateValueLabels {
    
    for (UILabel *label in self.valueLabels) {
        [label removeFromSuperview];
    }
    
    NSMutableArray<UILabel *> *valueLabels = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < self.numberOfSteps; ++i) {
        [valueLabels addObject:[self valueLabelForIndex:i selected:i == self.step]];
    }
    
    self.valueLabels = valueLabels;
}

- (CGFloat)CGPointDistanceSquared:(CGPoint)from to:(CGPoint)to {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
}

- (StepCenterPair)nearestStepCenterFromPoint:(CGPoint)point {
    
    CGFloat distance = FLT_MAX;
    NSInteger index = 0;
    CGPoint nearestStepCenter = [self centerPositionForIndex:index];
    
    for (NSInteger i = 0; i < self.numberOfSteps; ++i) {
        CGPoint stepCenter = [self centerPositionForIndex:i];
        CGFloat stepDistance = [self CGPointDistanceSquared:point to:stepCenter];
        
        if (stepDistance < distance) {
            distance = stepDistance;
            index = i;
            nearestStepCenter = stepCenter;
        }
    }
    
    StepCenterPair stepCenterPair = {};
    stepCenterPair.index = index;
    stepCenterPair.center = nearestStepCenter;
    
    return stepCenterPair;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    UIGestureRecognizerState state = [recognizer state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        
        CGPoint t = [recognizer translationInView:self];
        CGPoint center = CGPointMake(self.thumb.center.x + t.x, self.thumb.center.y);
        
        if (center.x + self.thumb.frame.size.width/2 > self.frame.size.width) {
            center = CGPointMake(self.frame.size.width - self.thumb.frame.size.width/2, center.y);
            
        } else if (center.x - self.thumb.frame.size.width/2 < 0) {
            center = CGPointMake(self.thumb.frame.size.width/2, center.y);
        }
        
        self.thumb.center = center;
        [recognizer setTranslation:CGPointZero inView:self];
        
    } else if (state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:kAnimationSpeed delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            StepCenterPair stepCenterPair = [self nearestStepCenterFromPoint:self.thumb.center];
            self.step = stepCenterPair.index;
            
        } completion:^(BOOL finished) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateKnotsLayer];
    [self updateKnots];
    [self updateTrack];
    [self updateThumbWithSelectedStep:self.step];
    [self updateValueLabels];
}

#if TARGET_INTERFACE_BUILDER
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
}
#endif

@end
