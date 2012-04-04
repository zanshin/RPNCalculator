//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Mark Nichols on 4/3/12.
//  Copyright (c) 2012 Mark H. Nichols. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL numberHasDecimalPoint;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic) int historyToClear;
@property (nonatomic) BOOL clearHistory;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize historyDisplay = _historyDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize numberHasDecimalPoint = _numberHasDecimalPoint;
@synthesize brain = _brain;
@synthesize historyToClear = _historyToClear;
@synthesize clearHistory = _clearHistory;

// setter for CalculatorBrain instance
- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

// digitPressed method
- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    
    
    if (self.userIsInTheMiddleOfEnteringANumber) 
    {
        if ([digit isEqualToString:@"."]) 
        {
            if (self.numberHasDecimalPoint) 
                return; //can only have one decimal point per number
            else 
                self.numberHasDecimalPoint = YES;
        }
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        if ([digit isEqualToString:@"."]) 
        {
            self.display.text = @"0.";
            self.numberHasDecimalPoint = YES;
        } else {
            self.display.text = digit;
        }
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    
}

// enterPressed method
- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self addToHistory:self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

// operationPressed method
- (IBAction)operationPressed:(UIButton *)sender 
{
    // if the user wants they can skip the enter after the final digit
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    
    [self addToHistory:sender.currentTitle];
    
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
    
    self.historyToClear = [self.historyDisplay.text length];
    [self addToHistory:resultString];
    self.clearHistory = YES;
}

// clearPressed method
- (IBAction)clearPressed:(id)sender 
{
    // clear button pressed, clear display and historyDisplay

    self.display.text = @"0";
    self.historyToClear = [self.historyDisplay.text length];
    self.clearHistory = YES;
    [self enterPressed];
    self.userIsInTheMiddleOfEnteringANumber = NO;

}

- (void)viewDidUnload {
    [self setHistoryDisplay:nil];
    [super viewDidUnload];
}

// clear historyDisplay
- (void)clearHistoryDisplay
{
    if (self.clearHistory) {
        self.historyDisplay.text = [self.historyDisplay.text substringFromIndex:self.historyToClear];
        self.clearHistory = NO;
    }
}

// append operands and operations to historyDisplay UILabel
- (void)addToHistory:(NSString *)textToAdd
{
    if (self.historyToClear) [self clearHistoryDisplay]; 
    
    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingString:textToAdd];
    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingString:@" "];
}
@end
