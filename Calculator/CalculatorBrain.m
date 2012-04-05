//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Mark Nichols on 4/3/12.
//  Copyright (c) 2012 Mark H. Nichols. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

//
// programStack getter
// Uses lazy instantiation to allocate and initialize object on its first use
//
- (NSMutableArray *)programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

//
// pushOperand method
// Add the latest operand (number) to the stack
//
- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

//
// performOperation method
// Build two sets, one for single operand operations (unary) and one for dual operand
// operations (binary). Use these to make sure we have the corrent number of operands
// for the operation being performed. 
//
- (double)performOperation:(NSString *)operation
{
    
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

//
// implement a getter for the program property
// only need a getter since it is a readonly property
//
- (id)program
{
    return [self.programStack copy];
}

//
// class method that returns a human readable copy of the current
// program 
//
+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in assignment #2";
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    // pop something off the stack
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    // handle number or operation
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        
        // sets to hold related operations
        NSSet *unaryOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"Sqrt", @"±", nil];
        NSSet *binaryOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
        
        double operand1, operand2;
        
        // handle single operand operations
        if ([unaryOperations containsObject:operation]) {
            operand1 = [self popOperandOffStack:stack];
            if (!operand1) return (result = 0);
            
            if ([@"sin" isEqualToString:operation]) result = sin(operand1);
            if ([@"cos" isEqualToString:operation]) result = cos(operand1);
            if ([@"Sqrt" isEqualToString:operation]) result = sqrt(operand1);
            if ([@"±" isEqualToString:operation]) result = -operand1;
            
        }
        
        // handle double operand operations
        if ([binaryOperations containsObject:operation]) {
            operand1 = [self popOperandOffStack:stack];
            operand2 = [self popOperandOffStack:stack];
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
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    
    return [self popOperandOffStack:stack];
    
}

@end
