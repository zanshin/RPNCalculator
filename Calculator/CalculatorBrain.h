//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Mark Nichols on 4/3/12.
//  Copyright (c) 2012 Mark H. Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;

//
// Assignment 2 additions
// A property to hold the program and two class methods to work with the program
//
@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

- (void)pushVariable:(NSString *)variable;

@end
