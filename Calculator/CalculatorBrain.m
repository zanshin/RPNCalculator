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

#pragma mark - Getters
- (NSMutableArray *)programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

#pragma mark - Instance methods

// add operands to the stack
- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

// add variables to the stack
- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

// add operations to the stack
- (void)pushOperation:(NSString *) operation {
    [self.programStack addObject:operation];    
}

// perform calculation required by the operation
- (double)performOperation:(NSString *)operation
{
    
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

#pragma mark - Class methods

// helper methods to work with our supported operations

// return TRUE if the operation is a supported one
+ (BOOL)isOperation:(NSString *)operation
{
    NSSet *validOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"Sqrt", @"±",@"+", @"-", @"*", @"/", nil];
    return [validOperations containsObject:operation];
}

// return TRUE if the operation requires only one operand
+ (BOOL)unaryOperator:(NSString *)operation
{
    NSSet *unaryOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"Sqrt", @"±", nil];
    return [unaryOperations containsObject:operation];
}

// return TRUE if the operation requires two operands
+ (BOOL)binaryOperator:(NSString *)operation
{
    NSSet *binaryOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    return [binaryOperations containsObject:operation];
}

// return a human readable string of the current program
+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in assignment #2";
}

// if the topOfStack is a number return it, otherwise determine the operation
// and perform the required calculation
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
        
        double operand1, operand2;
        
        // handle single operand operations
        if ([self unaryOperator:operation]) {
            operand1 = [self popOperandOffStack:stack];
            if (!operand1) return (result = 0);
            
            if ([@"sin" isEqualToString:operation]) result = sin(operand1);
            if ([@"cos" isEqualToString:operation]) result = cos(operand1);
            if ([@"Sqrt" isEqualToString:operation]) result = sqrt(operand1);
            if ([@"±" isEqualToString:operation]) result = -operand1;
        }
        
        // handle double operand operations
        if ([self binaryOperator:operation]) {
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

// vanilia runProgram - just calls runProgram:usingVariableValues with a nil dictionary
+ (double)runProgram:(id)program
{
    NSLog(@"runProgram");
    return [self runProgram:program usingVariableValues:nil];
}

// runProgram using variables locates variables and replaces them with the 
// appropriate values from the dictionary
+ (double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues 
{
    NSLog(@"runProgram:usingVariableValues");
    if ([program isKindOfClass:[NSArray class]])
    {
        NSMutableArray *stack= [program mutableCopy];
        
        for (int i=0; i < [stack count]; i++) 
        {
            id obj = [stack objectAtIndex:i]; 
            if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) 
            {  
                id value = [variableValues objectForKey:obj];           
                if (![value isKindOfClass:[NSNumber class]]) 
                    value = [NSNumber numberWithInt:0]; // if no value substitute zero

                // replace program variable with value.
                [stack replaceObjectAtIndex:i withObject:value];
            }       
        }   
        
        // stack now contains operands (values) and operations, time to calculate
        return [self popOperandOffStack:stack];  
    } 
    else 
    {
        return 0; // in the unlikely event we weren't passed an array
    }
}

// returns a set containing all the variables used in the program
+ (NSSet *)variablesUsedInProgram:(id)program { 
    
    NSLog(@"variablesUsedInProgram");
    if (![program isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableSet *variables = [NSMutableSet set];
    
    for (id obj in program) {
        if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) {
            [variables addObject:obj];  
        }
    }   
    // if no variables return nil
    if ([variables count] == 0) 
        return nil; 
    else 
        return [variables copy];
}

@end
