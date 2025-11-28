#[derive(Debug)]
pub enum Token {
    Number(f64),
    Operator(OpType),
    Paranthesis(char),
}

#[derive(Debug)]
pub enum OpType {
    Add,
    Subtract,
    Divide,
    Multiply,
}
