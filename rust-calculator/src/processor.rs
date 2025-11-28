use anyhow::{Context, Result, bail};

use crate::token::{OpType, Token};

fn get_precedence(op: &OpType) -> u8 {
    match op {
        OpType::Add | OpType::Subtract => 1,
        OpType::Divide | OpType::Multiply => 2,
    }
}

pub fn shunting_yard(tokens: Vec<Token>) -> Result<Vec<Token>> {
    let mut op_stack = Vec::new();
    let mut output_queue = Vec::new();

    for token in tokens {
        match token {
            Token::Paranthesis(c) => {
                if c == '(' {
                    op_stack.push(Token::Paranthesis(c));
                } else {
                    // c == ')'
                    loop {
                        match op_stack.pop() {
                            Some(popped_token) => match popped_token {
                                Token::Paranthesis('(') => break,
                                token_to_output => output_queue.push(token_to_output),
                            },
                            None => {
                                bail!("Mismatched parantheses (no matching opening bracket found)")
                            }
                        }
                    }
                }
            }
            Token::Number(n) => {
                output_queue.push(Token::Number(n));
            }
            Token::Operator(op) => {
                let current_precedence = get_precedence(&op);

                while let Some(top_token) = op_stack.last() {
                    if let Token::Operator(top_op) = top_token {
                        if get_precedence(top_op) >= current_precedence {
                            output_queue.push(op_stack.pop().unwrap());
                        } else {
                            break;
                        }
                    } else {
                        break;
                    }
                }

                op_stack.push(Token::Operator(op));
            }
        }
    }

    while let Some(token) = op_stack.pop() {
        match token {
            Token::Operator(_) => output_queue.push(token),
            Token::Paranthesis(_) => bail!("Mismatched parantheses"),
            _ => {}
        }
    }

    Ok(output_queue)
}

pub fn process_expr(expr_queue: Vec<Token>) -> Result<f64> {
    let mut exp_stack = Vec::new();

    for token in expr_queue {
        match token {
            Token::Operator(op) => {
                let second = exp_stack.pop().context("Missing left operand")?;
                let first = exp_stack.pop().context("Missing right operand")?;

                let calculation_result = match op {
                    OpType::Add => first + second,
                    OpType::Subtract => first - second,
                    OpType::Multiply => first * second,
                    OpType::Divide => {
                        if second == 0.0 {
                            bail!("Attempt to divide by 0")
                        }

                        first / second
                    }
                };

                exp_stack.push(calculation_result);
            }
            Token::Number(num) => {
                exp_stack.push(num);
            }
            _ => bail!("Invalid token found: {:?}", token),
        }
    }

    match exp_stack.pop() {
        Some(final_result) if exp_stack.is_empty() => Ok(final_result),
        Some(_) => {
            bail!("Too many operands")
        }
        None => bail!("Empty or invalid expression"),
    }
}
