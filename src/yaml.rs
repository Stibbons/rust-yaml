#![feature(macro_rules)]
#![feature(globs)]

use std::collections::HashMap;
use std::collections::TreeMap;
use std::char;
use std::f64;
use std::fmt;
use std::io;
use std::num;
use std::str;
use std::vec::Vec;
use std::string;


/// Represents a Yaml value
pub enum Yaml
{
    Number(f64),
    String(YamlString),
    Boolean(bool),
    List(YamlList),
    Dict(YamlDict),
    Null,
}
pub type YamlString = string::String;
pub type YamlList = Vec<Yaml>;
pub type YamlDict = TreeMap<string::String, Yaml>;


/// The errors that can arise while parsing a JSON stream.
#[deriving(Clone, PartialEq)]
pub enum ErrorCode {
    Todo,
}

#[deriving(Clone, PartialEq)]
pub enum YamlError {
    /// msg, line, col
    SyntaxError(ErrorCode, uint, uint),
    IoError(io::IoErrorKind, &'static str),
}


pub struct Parser<T>
{
    rdr: T,
    line: int,
    col: int,
}
impl<T: Iterator<char>> Parser<T>
{
    /// Create a JSON Builder.
    pub fn new(rdr: T) -> Parser<T>
    {
        let mut p = Parser {
            rdr: rdr,
            line: 1,
            col: 0,
        };
        p
    }

    // Decode a Yaml value from a Parser.
    pub fn parse(&mut self) -> Result<Yaml, YamlError>
    {
        Ok(String("string".to_string()))
    }
}

pub fn from_str(s: &str) -> Result<Yaml, YamlError>
{
    let mut parser = Parser::new(s.chars());
    parser.parse()
}

#[cfg(test)]
mod tests
{
    mod test_utils
    {
        macro_rules! assert_eq(
            ($given:expr , $expected:expr) =>
            ({
                match (&($given), &($expected))
                {
                    (given_val, expected_val) =>
                    {
                        // check both directions of equality....
                        if !((*given_val == *expected_val) &&
                             (*expected_val == *given_val))
                        {
                            panic!("assertion failed: expected `{}`, actual `{}`", *given_val, *expected_val)
                        }
                    }
                }
            })
        )
    }
    mod decoder
    {
        use super::test_utils::*;
        use super::super::*;

        #[test]
        fn test_basic_string()
        {
            assert_eq!("string", from_str("string"));
        }
    }
}
