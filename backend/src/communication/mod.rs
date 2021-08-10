use serde::{Deserialize, Serialize};

use self::pipes::{create_pipes, delete_pipes, read_from_pipe, write_on_pipe};

mod pipes;

#[cfg(all(test, debug_assertions))]
const INPUT_PATH: &'static str = "./input_test_pipe";
#[cfg(all(test, debug_assertions))]
const OUTPUT_PATH: &'static str = "./output_test_pipe";
#[cfg(not(any(test, debug_assertions)))]
const INPUT_PATH: &'static str = "/opt/MsiPowerCenter/pipes/input";
#[cfg(not(any(test, debug_assertions)))]
const OUTPUT_PATH: &'static str = "/opt/MsiPowerCenter/pipes/output";
#[cfg(all(not(test), debug_assertions))]
const INPUT_PATH: &'static str = "../input_debug";
#[cfg(all(not(test), debug_assertions))]
const OUTPUT_PATH: &'static str = "../output_debug";

#[derive(Debug, PartialEq, Deserialize)]
pub enum Category{
    CoolerBoost,
    ChargingLimit,
    Profile,
    AvailableProfiles
}

impl Category{
    fn from_name(name: String) -> Option<Self>{
        match name.as_str() {
            "Profile" => Some(Category::Profile),
            "CoolerBoost" => Some(Category::CoolerBoost),
            "ChargingLimit" => Some(Category::ChargingLimit),
            "AvailableProfiles" => Some(Category::AvailableProfiles),
            _ => None
        }
    }
}

#[derive(PartialEq, Debug)]
pub enum Value{
    String(String),
    Int(i32),
    Bool(bool)
}

#[derive(PartialEq, Debug)]
pub struct ToGet{
    pub category: Category,
}

#[derive(PartialEq, Debug)]
pub struct ToSet{
    pub category: Category,
    pub value: Value
}

#[derive(PartialEq, Debug)]
pub struct Command{
    pub to_set: Option<ToSet>,
    pub to_get: Option<ToGet>,
}

#[derive(Clone)]
pub struct CommunicationService{
    input_path: String,
    output_path: String
}

impl CommunicationService{

    pub fn new() -> Self{
        match create_pipes(String::from(INPUT_PATH), String::from(OUTPUT_PATH)) {
            Ok(()) => CommunicationService{input_path: String::from(INPUT_PATH), output_path: String::from(OUTPUT_PATH)},
            Err(s) => panic!("{}", s)
        }
    }

    #[cfg(test)]
    pub fn new_for_test(number: i32) -> Self{
        let input = String::from(&format!("{}{}", INPUT_PATH, number));
        let output = String::from(&format!("{}{}", OUTPUT_PATH, number));
        match create_pipes(input.to_owned(), output.to_owned()) {
            Ok(()) => CommunicationService{input_path: input, output_path: output},
            Err(s) => panic!("{}", s)
        }
    }

    pub fn get_command(&self) -> Result<Command,String>{
        let result = read_from_pipe(self.input_path.to_owned()).map_err(|e|format!("Error reading input: {}", e))?;
        let json:serde_json::Value = serde_json::from_str(result.as_str()).map_err(|e|format!("parse error: {}", e))?;
        let mut to_get = None;
        if let serde_json::Value::Object(o) = json["toGet"].to_owned() {
            if let serde_json::Value::String(s) = o["category"].to_owned(){
                if let Some(c) = Category::from_name(s){
                    to_get = Some(ToGet{category: c});
                }
            }
        };
        let mut to_set = None;
        if let serde_json::Value::Object(o) = json["toSet"].to_owned() {
            if let serde_json::Value::String(s) = o["category"].to_owned(){
                if let Some(c) = Category::from_name(s){
                    let value = o["value"].to_owned();
                    if !value.is_null(){
                        let parsed_value;
                        match value{
                            serde_json::Value::Bool(b) => parsed_value = Value::Bool(b),
                            serde_json::Value::String(s) => parsed_value = Value::String(s),
                            serde_json::Value::Number(n) => parsed_value = Value::Int(n.as_i64().unwrap() as i32),
                            _ => return Err(String::from("wrong value type"))
                        };
                        to_set = Some(ToSet{category: c, value: parsed_value});
                    }
                }
            }
        };
        Ok(Command{to_get,to_set})
    }

    pub fn write_object<T>(&self, object: T) -> Result<(), String> where T: Serialize{
        let mut string = serde_json::to_string(&object).map_err(|e|format!("error serializing {}",e))?;
        string.push('\n');
        self.write_output(string)
    }

    pub fn send_stop_command(&self) -> Result<(), String>{
        write_on_pipe(self.input_path.clone(), "{}".to_string()).map_err(|e|format!("error sending command: {}",e))
    }

    pub fn send_error(&self, error: String) -> Result<(), String>{
        self.write_output(format!("{{\"error\": \"{}\"}}",error))
    }

    fn write_output(&self, value: String) -> Result<(), String>{
        write_on_pipe(self.output_path.clone(), value).map_err(|e| format!("error writing: {}", e))
    }
}

impl Drop for CommunicationService{
    fn drop(&mut self) {
        match delete_pipes(self.input_path.to_owned(), self.output_path.to_owned()){
            Ok(()) => (),
            Err(e) => eprintln!("error deleting pipes: {}", e)
        }
    }
}

#[cfg(test)]
mod tests{
    use std::fs::{File, metadata};
    use std::io::Read;
    use std::thread::{self, JoinHandle};

    use super::Value;

    use super::{ToGet, ToSet};
    use super::{Command, CommunicationService, pipes::write_on_pipe};

    #[test]
    fn can_create_and_delete_pipes() -> Result<(), String>{
        let input_path;
        let output_path;
        {
            let service = CommunicationService::new_for_test(1);
            input_path = service.input_path.to_owned();
            output_path = service.output_path.to_owned();
            metadata(input_path.to_owned()).map_err(|e| format!("Input not created {}", e))?;
            metadata(output_path.to_owned()).map_err(|e| format!("Output not created {}", e))?;
        }
        match metadata(input_path){
            Err(_e) => {
                match metadata(output_path){
                    Err(_e) => Ok(()),
                    Ok(_data) => Err(String::from("Output not deleted"))
                }
            },
            Ok(_data) => Err(String::from("Input not deleted"))
        }
    }

    fn can_receive_command(string: &'static str, command: Command, number: i32) -> Result<(),String>{
        let service = CommunicationService::new_for_test(number);
        let input_path = service.input_path.to_owned();
        let child = thread::spawn(move ||{
            write_on_pipe(input_path, String::from(string))
        });
        let received = service.get_command()?;
        assert_eq!(received, command);
        child.join().map_err(|e| format!("error joining: {:?}", e))?.map_err(|e|format!("error joining: {}", e))
    }

    #[test]
    fn can_receive_all_commands() -> Result<(),String>{
        can_receive_command(
            "{\"to_get\": {\"category\":\"Profile\"}}", 
            Command{to_get: Some(ToGet{category: super::Category::Profile}), to_set: None }, 
            2)?;
        can_receive_command(
            "{\"to_set\": {\"category\":\"CoolerBoost\", \"value\": false}, \"to_get\": {\"category\": \"CoolerBoost\"}}", 
            Command{to_get: Some(ToGet{category: super::Category::CoolerBoost}), to_set: Some(ToSet{category: super::Category::CoolerBoost, value: Value::Bool(false)}) }, 
            2)?;
        can_receive_command(
            "{\"to_set\": {\"category\":\"Profile\", \"value\": \"Performance\"}}", 
            Command{to_get: None, to_set: Some(ToSet{ category: super::Category::Profile, value: Value::String(String::from("Performance")) }) }, 
            3)
    }

    #[test]
    fn can_write_output() -> Result<(), String>{
        let test = "abcefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        let service = CommunicationService::new_for_test(11);
        let output = service.output_path.clone();
        let child: JoinHandle<Result<String, std::io::Error>> = thread::spawn(move ||{
            let mut file = File::open(output)?;
            let mut result = String::new();
            file.read_to_string(&mut result)?;
            Ok(result)
        });
        service.write_output(test.to_string())?;
        match child.join().map_err(|e| format!("error joining: {:?}", e))?{
            Ok(s) if s == test => Ok(()),
            Ok(s) => Err(format!("result '{}' is different from expected '{}'", s, test)),
            Err(_) => Err(String::from("error reading"))
        }
    }
}