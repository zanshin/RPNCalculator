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
    return [[CalculatorBrain runProgram:self.program] doubleValue];
}

#pragma mark - Class methods

// helper methods to work with our supported operations

// return TRUE if the operation is a supported one
+ (BOOL)isOperation:(NSString *)operation
{
    NSSet *validOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"Sqrt", @"±",@"+", @"-", @"*", @"/", nil];
    return [validOperations containsObject:operation];
}

// return TRUE if the operation requires no operands
+ (BOOL)nonaryOperator:(NSString *)operation
{
    NSSet *nonaryOperations = [[NSSet alloc] initWithObjects:@"Pi", nil];
    return [nonaryOperations containsObject:operation];
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

// return TRUE if the program is an NSArray
+ (BOOL)isValidProgram:(id)program {
    return [program isKindOfClass:[NSArray class]];
}

// return a human readable string of the current program
+ (NSString *)descriptionOfProgram:(id)program
{
    // Check program is valid and if not return message
    if (![self isValidProgram:program]) return @"Invalid program!";
    
    NSMutableArray *stack= [program mutableCopy];
    NSMutableArray *expressionArray = [NSMutableArray array];
    
    // Call recursive method to describe the stack, removing superfluous brackets at the
    // start and end of the resulting expression. Add the result into an expression array
    // and continue if there are still more items in the stack. 
    // our description Array, and if the 
    while (stack.count > 0) {
        [expressionArray addObject:[self stripParens:[self descriptionOffTopOfStack:stack]]];
    }
    
    // Return a list of comma seperated programs
    return [expressionArray componentsJoinedByString:@","]; 
}

+ (NSString *)descriptionOffTopOfStack:(NSMutableArray *)stack {
    
    NSString *description;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject]; else return @"";
    
    // for numbers just return as a string
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        return [topOfStack description];
    }       
    else if ([topOfStack isKindOfClass:[NSString class]]) { 
        // for no operand operation, or variables return description in the form "x"
        if (![self isOperation:topOfStack] || [self nonaryOperator:topOfStack]) 
            description = topOfStack;
        // for unary operation return in the form "f(x)"
        else if ([self unaryOperator:topOfStack]) 
        {
            NSString *x = [self stripParens:[self descriptionOffTopOfStack:stack]];
            description = [NSString stringWithFormat:@"%@(%@)", topOfStack, x]; 
        }
        // for binary operations return in the form "x op. y"
        else if ([self binaryOperator:topOfStack]) {
            NSString *y = [self descriptionOffTopOfStack:stack];
            NSString *x = [self descriptionOffTopOfStack:stack];
            
            // for + and - add parens to support precedence rules 
            if ([topOfStack isEqualToString:@"+"] || 
                [topOfStack isEqualToString:@"-"]) {               
                description = [NSString stringWithFormat:@"(%@ %@ %@)", [self stripParens:x], topOfStack, [self stripParens:y]];
            } 
            // for * or / no need for parens
            else {
                description = [NSString stringWithFormat:@"%@ %@ %@",
                               x, topOfStack ,y];
            }
        }       
    }
    return description ;        
}

+ (NSString *)stripParens:(NSString *)expression {
    
    NSString *description = expression;
    
    // Check to see if there is a paren at the start and end of the expression
    // If so, then strip the description of these parens and return.
    if ([expression hasPrefix:@"("] && [expression hasSuffix:@")"]) {
        description = [description substringFromIndex:1];
        description = [description substringToIndex:[description length] - 1];
    }   
    
    // Also need to do a final check, to cover the case where removing the parens
    // results in a + b) * (c + d. Have a look at the position of the brackets and
    // if there is a ) before a (, then we need to revert back to expression
    NSRange openParen = [description rangeOfString:@"("];
    NSRange closeParen = [description rangeOfString:@")"];
    
    if (openParen.location <= closeParen.location) return description;
    else return expression; 
}

// if the topOfStack is a number return it, otherwise determine the operation
// and perform the required calculation
+ (id)popOperandOffStack:(NSMutableArray *)stack
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
        
        id operand1, operand2;
        double dOperand1, dOperand2;
        
        // handle single operand operations
        if ([self unaryOperator:operation]) {
            operand1 = [self popOperandOffStack:stack];
            if (!operand1) return [@"" stringByAppendingFormat:@"Insufficient operands for %@", operation];
            
            dOperand1 = [(NSNumber *) operand1 doubleValue];
            
            if ([@"sin" isEqualToString:operation]) result = sin(dOperand1);
            if ([@"cos" isEqualToString:operation]) result = cos(dOperand1);
            if ([@"Sqrt" isEqualToString:operation]) result = sqrt(dOperand1);
            if ([@"±" isEqualToString:operation]) result = -dOperand1;
        }
        
        // handle double operand operations
        if ([self binaryOperator:operation]) {
            operand1 = [self popOperandOffStack:stack];
            operand2 = [self popOperandOffStack:stack];
            if (!operand1) return [@"" stringByAppendingFormat:@"Insufficient operands for %@", operation];
            if (!operand2) return [@"" stringByAppendingFormat:@"Insufficient operands for %@", operation];
            
            dOperand1 = [(NSNumber *) operand1 doubleValue];
            dOperand2 = [(NSNumber *) operand2 doubleValue];
            
            if ([@"+" isEqualToString:operation]) result = dOperand2 + dOperand1;
            if ([@"-" isEqualToString:operation]) result = dOperand2 - dOperand1;
            if ([@"*" isEqualToString:operation]) result = dOperand2 * dOperand1;
            if ([@"/" isEqualToString:operation]) {
                if (operand1)
                    result = dOperand2 / dOperand1;
                else 
                    result = 0;
            }
        }
        
        // handle zero operand operations
        if ([@"Pi" isEqualToString:operation]) result = M_PI;
    }
    
    return [NSNumber numberWithDouble:result];
}

// vanilia runProgram - just calls runProgram:usingVariableValues with a nil dictionary
+ (id)runProgram:(id)program
{
    NSLog(@"runProgram");
    return [self runProgram:program usingVariableValues:nil];
}

// runProgram using variables locates variables and replaces them with the 
// appropriate values from the dictionary
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues 
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
