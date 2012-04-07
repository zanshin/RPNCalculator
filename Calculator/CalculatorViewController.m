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

@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL numberHasDecimalPoint;
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

// CalculatorBrain getter
// Uses lazy instantiation to allocate and initialize object on its first use
- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

//
// digitPressed method
// Handle pressing of any of the digit buttons (0-9) and the decimal button (.).
// Allows only a single decimal per number, allows for leading decimal.
//
- (IBAction)digitPressed:(UIButton *)sender 
{
    NSLog(@"digitPressed");
    
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

//
// enterPressed method
// Captures the number which has been entered a digit at a time, adds the number
// to the history display, toggles userIsInTheMiddleOfEnteringANumber BOOL
//
- (IBAction)enterPressed 
{
    NSLog(@"enterPressed");
    
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self addToHistory:self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

//
// operationPressed method
// Captures the operation selected. Adds that operation to the history display. Calls
// performOperation method on CalculatorBrain instance and displays result.
// History display is truncated to only show operands for last operation.
//
- (IBAction)operationPressed:(UIButton *)sender 
{
    NSLog(@"operationPressed");
    
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

//
// clearPressed method
// Clears main display and history display.
//
- (IBAction)clearPressed:(id)sender 
{
    NSLog(@"clearPressed");
    
    // clear button pressed, clear display and historyDisplay

    self.display.text = @"0";
    self.historyToClear = [self.historyDisplay.text length];
    self.clearHistory = YES;
    [self clearHistoryDisplay];
    //[self enterPressed];
    self.userIsInTheMiddleOfEnteringANumber = NO;

}

//
// clearErrorPressed method
// Allows user to remove, one digit at a time, numbers from the display.
// Last digit displayed, i.e., the first one entered, cannot currently be removed.
// Can only remove digits while a number is being entered.
//
- (IBAction)clearErrorPressed:(id)sender 
{
    NSLog(@"clearErrorPressed");
    
    if (self.userIsInTheMiddleOfEnteringANumber)
    {
        NSInteger currentDisplayLength = self.display.text.length;
        if (currentDisplayLength == 1)
        {
            self.userIsInTheMiddleOfEnteringANumber = NO;
        } else {
            NSString *lastDigit = [self.display.text substringFromIndex:currentDisplayLength - 1];
            self.display.text = [self.display.text substringToIndex:currentDisplayLength -1];
            if ([lastDigit isEqualToString:@"."])
                self.numberHasDecimalPoint = NO;
        }
    }
}

//
// clearhistoryDisplay method
// Clears the history display using the index value captured when last operation was entered.
//
- (void)clearHistoryDisplay
{
    NSLog(@"clearHistoryDisplay");
    
    if (self.clearHistory) {
        self.historyDisplay.text = [self.historyDisplay.text substringFromIndex:self.historyToClear];
        self.clearHistory = NO;
    }
}

//
// addToHistory method
// Append operands and operations to historyDisplay.
//
- (void)addToHistory:(NSString *)textToAdd
{
    NSLog(@"addToHistory");
    
    if (self.historyToClear) [self clearHistoryDisplay]; 
    
    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingString:textToAdd];
    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingString:@" "];
}

//
// test1Pressed method
// Construct a test program, populate it with values and operations, and run it
//
- (IBAction)test1Pressed 
{
    // create a test instance of the brain
    CalculatorBrain *testBrain = [self brain];
    
    // Setup the brain
    [testBrain pushVariable:@"a"];
    [testBrain pushVariable:@"a"];
    [testBrain pushOperation:@"*"];
    [testBrain pushVariable:@"b"];
    [testBrain pushVariable:@"b"];
    [testBrain pushOperation:@"*"];
    [testBrain pushOperation:@"+"];
    [testBrain pushOperation:@"sqrt"];  
    
    // Retrieve the program
    NSArray *program = testBrain.program;
    
    // Setup the dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys: 
                                [NSNumber numberWithDouble:3], @"a",
                                [NSNumber numberWithDouble:4], @"b", nil];
    
    // Run the program with variables
    NSLog(@"Running the program with variables returns the value %g",
          [CalculatorBrain runProgram:program usingVariableValues:dictionary]);
    
    // List the variables in program    
    NSLog(@"Variables in program are %@", 
          [[CalculatorBrain variablesUsedInProgram:program] description]);
}


@end
