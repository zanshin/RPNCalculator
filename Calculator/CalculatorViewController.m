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
@property (nonatomic, strong) NSDictionary *testVariableValues;

//@property (nonatomic) int historyToClear;
//@property (nonatomic) BOOL clearHistory;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize historyDisplay = _historyDisplay;
@synthesize variablesDisplay = _variablesDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize numberHasDecimalPoint = _numberHasDecimalPoint;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

//@synthesize historyToClear = _historyToClear;
//@synthesize clearHistory = _clearHistory;

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
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([digit isEqualToString:@"."]) {
            if (self.numberHasDecimalPoint) 
                return; //can only have one decimal point per number
            else 
                self.numberHasDecimalPoint = YES;
        }
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        if ([digit isEqualToString:@"."]) {
            self.display.text = @"0.";
            self.numberHasDecimalPoint = YES;
        } else 
            self.display.text = digit;
        
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
    //[self addToHistory:self.display.text];
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
    
    //[self addToHistory:sender.currentTitle];
    
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
    
    self.historyDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    [self synchronizeView];
    //self.historyToClear = [self.historyDisplay.text length];
    //[self addToHistory:resultString];
    //self.clearHistory = YES;
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
    self.historyDisplay.text = @"";
    //self.historyToClear = [self.historyDisplay.text length];
    //self.clearHistory = YES;
    //[self clearHistoryDisplay];
    //[self enterPressed];
    //self.userIsInTheMiddleOfEnteringANumber = NO;
    //[self synchronizeView];

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
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        // Remove the last digit or point from the display
        self.display.text =[self.display.text substringToIndex:
                            [self.display.text length] - 1]; 
        
        // If we are left with no digits or a "-" digit
        if ( [self.display.text isEqualToString:@""]
            || [self.display.text isEqualToString:@"-"]) {
            
            [self synchronizeView];     
        }   
    } else {
        // Remove the last item from the stack and synchronize the view
        [self.brain removeLastItem];
        [self synchronizeView];
    } 
}

//
// variablePressed method
// push variable pressed onto the program stack
//
- (IBAction)variablePressed:(UIButton *)sender 
{
    [self.brain pushVariable:sender.currentTitle];
}

//
// synchronizeView method
// one place to manage all view related activities
//
-(void)synchronizeView {    
    // Find the result by running the program passing in the test variable values
    id result = [CalculatorBrain runProgram:self.brain.program 
                        usingVariableValues:self.testVariableValues];   
    
    // If the result is a string, then display it, otherwise get the Number's description
    if ([result isKindOfClass:[NSString class]])    
        self.display.text = result;
    else 
        self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
    
    // Now the calculation label, from the latest description of program    
    self.historyDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    // And finally the variables text, with a bit of formatting
    self.variablesDisplay.text = [[[[[[[self programVariableValues] description]
                               stringByReplacingOccurrencesOfString:@"{" withString:@""]
                              stringByReplacingOccurrencesOfString:@"}" withString:@""]
                             stringByReplacingOccurrencesOfString:@";" withString:@""]
                            stringByReplacingOccurrencesOfString:@"\"" withString:@""]
                           stringByReplacingOccurrencesOfString:@"<null>" withString:@"0"];
    
    // And the user isn't in the middle of entering a number
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (NSDictionary *)programVariableValues {   
    
    // Find the variables in the current program in the brain as an array
    NSArray *variableArray = 
    [[CalculatorBrain variablesUsedInProgram:self.brain.program] allObjects];
    
    // Return a description of a dictionary which contains keys and values for the keys 
    // that are in the variable array
    return [self.testVariableValues dictionaryWithValuesForKeys:variableArray];
}


//
// clearhistoryDisplay method
// Clears the history display using the index value captured when last operation was entered.
//
//- (void)clearHistoryDisplay
//{
//    NSLog(@"clearHistoryDisplay");
//    
//    if (self.clearHistory) {
//        self.historyDisplay.text = [self.historyDisplay.text substringFromIndex:self.historyToClear];
//        self.clearHistory = NO;
//    }
//}

//
// addToHistory method
// Append operands and operations to historyDisplay.
//
//- (void)addToHistory:(NSString *)textToAdd
//{
//    NSLog(@"addToHistory");
//    
//    if (self.historyToClear) [self clearHistoryDisplay]; 
//    
//    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingString:textToAdd];
//    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingString:@" "];
//}

#pragma mark - Test methods
- (IBAction)test1Pressed 
{
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:-4], @"x",
                               [NSNumber numberWithDouble:3], @"a",
                               [NSNumber numberWithDouble:4], @"b", nil];
    [self synchronizeView];
}

- (IBAction)test2Pressed 
{
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:-5], @"x", nil];
    [self synchronizeView];
}

- (IBAction)test3Pressed 
{
    self.testVariableValues = nil;  
    [self synchronizeView];
}


- (void)viewDidUnload {
    [self setVariablesDisplay:nil];
    [super viewDidUnload];
}
@end
