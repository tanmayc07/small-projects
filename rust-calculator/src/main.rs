use anyhow::Result;
use std::io;

pub mod processor;
pub mod token;
pub mod tokenize;

use crate::{
    processor::{process_expr, shunting_yard},
    tokenize::tokenize,
};

fn main() -> Result<()> {
    let mut buffer = String::new();

    println!("Enter the expression:");
    io::stdin().read_line(&mut buffer)?;

    let trimmed_input = buffer.trim();
    let tokens = tokenize(trimmed_input)?;

    let expression_queue = shunting_yard(tokens)?;

    let value = process_expr(expression_queue)?;
    println!("Result = {}", value);

    Ok(())
}
