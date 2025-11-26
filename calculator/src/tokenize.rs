use crate::token::{OpType, Token};
use anyhow::{Result, bail};

fn parse_f64(buf: &str) -> Result<f64> {
    Ok(buf.parse::<f64>()?)
}

pub fn tokenize(inp: &str) -> Result<Vec<Token>> {
    let mut tokens: Vec<Token> = Vec::new();
    let mut current_num_str = String::new();

    let mut chars = inp.chars().peekable();

    while let Some(c) = chars.next() {
        if c.is_ascii_whitespace() {
            continue;
        } else if c.is_ascii_digit() {
            current_num_str.push(c);
            while let Some(&c) = chars.peek() {
                if c.is_ascii_digit() {
                    if let Some(c) = chars.next() {
                        current_num_str.push(c);
                    }
                } else {
                    break;
                }
            }

            let num = parse_f64(&current_num_str)?;
            tokens.push(Token::Number(num));

            current_num_str.clear();
        } else if c == '(' || c == ')' {
            tokens.push(Token::Paranthesis(c));
        } else {
            let op = match c {
                '+' => Token::Operator(OpType::Add),
                '-' => Token::Operator(OpType::Subtract),
                '*' => Token::Operator(OpType::Multiply),
                '/' => Token::Operator(OpType::Divide),
                _ => bail!("Invalid char found: {}", inp),
            };

            tokens.push(op);
        }
    }

    Ok(tokens)
}
