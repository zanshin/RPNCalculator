//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Mark Nichols on 4/3/12.
//  Copyright (c) 2012 Mark H. Nichols. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *operandStack;
@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

// use thesetter to insure operandStack isn't nil when we need it
- (NSMutableArray *)operandStack
{
    if (_operandStack == nil) _operandStack = [[NSMutableArray alloc] init];
    return _operandStack;
}

//
// pushOperand method
// Add the latest operand (number) to the stack
//
- (void)pushOperand:(double)operand
{
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]];
}

//
// popOperand method
// Remove the top item from the stack. Since the stack is implemented as an
// array, we just remove the last object from the array.
//
- (double)popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if (operandObject) [self.operandStack removeLastObject];
    return [operandObject doubleValue];
}

//
// performOperation method
// Build two sets, one for single operand operations (unary) and one for dual operand
// operations (binary). Use these to make sure we have the corrent number of operands
// for the operation being performed. 
//
- (double)performOperation:(NSString *)operation
{
    double result = 0;
    
    // sets to hold related operations
    NSSet *unaryOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"Sqrt", @"±", nil];
    NSSet *binaryOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    
    double operand1, operand2;
    
    // handle single operand operations
    if ([unaryOperations containsObject:operation]) {
        operand1 = [self popOperand];
        if (!operand1) return (result = 0);

        if ([@"sin" isEqualToString:operation]) result = sin(operand1);
        if ([@"cos" isEqualToString:operation]) result = cos(operand1);
        if ([@"Sqrt" isEqualToString:operation]) result = sqrt(operand1);
        if ([@"±" isEqualToString:operation]) result = -operand1;

    }

    // handle double operand operations
    if ([binaryOperations containsObject:operation]) {
        operand1 = [self popOperand];
        operand2 = [self popOperand];
        if (!operand1) return (result = 0);
        if (!operand2) return (result = 0);
        
        if ([@"+" isEqualToString:operation]) result = operand2 + operand1;
        if ([@"-" isEqualToString:operation]) result = operand2 - operand1;
        if ([@"*" isEqualToString:operation]) result = operand2 * operand1;
        if ([@"/" isEqualToString:operation]) {
            if (operand1)
                result = operand2 / operand1;
            else 
                result = 0;
        }
    }
    
    // handle zero operand operations
    if ([@"Pi" isEqualToString:operation]) result = M_PI;
    
    
    [self pushOperand:result];
    return result;
}

@end
