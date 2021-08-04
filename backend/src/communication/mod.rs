use self::pipes::{create_pipes, delete_pipes, read_from_pipe, write_on_pipe};

mod pipes;

#[cfg(not(test))]
const INPUT_PATH: &'static str = "/opt/MsiPowerCenter/pipes/input";
#[cfg(not(test))]
const OUTPUT_PATH: &'static str = "/opt/MsiPowerCenter/pipes/output";
#[cfg(test)]
const INPUT_PATH: &'static str = "./input_test_pipe";
#[cfg(test)]
const OUTPUT_PATH: &'static str = "./output_test_pipe";

#[derive(Debug, PartialEq)]
pub enum Command{
    Get,
    Set,
    Performance,
    Balanced,
    Silent,
    Battery,
    CoolerBoost,
    ChargingLimit,
    Profile
}

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

    pub fn get_input(&self) -> Result<Command,String>{
        match read_from_pipe(self.input_path.to_owned()){
            Ok(s) => {
                match s.as_str() {
                    "GET" => Ok(Command::Get),
                    "SET" => Ok(Command::Set),
                    "PERFORMANCE" => Ok(Command::Performance),
                    "BALANCED" => Ok(Command::Balanced),
                    "SILENT" => Ok(Command::Silent),
                    "BATTERY" => Ok(Command::Battery),
                    "COOLER_BOOST" => Ok(Command::CoolerBoost),
                    "CHARGING_LIMIT" => Ok(Command::ChargingLimit),
                    "PROFILE" => Ok(Command::Profile),
                    _ => Err(format!("Wrong Command {}", s)),
                }
            },
            Err(e) => Err(format!("Error reading input: {}", e)),
        }
    }

    pub fn write_output(&self, value: String) -> Result<(), String>{
        write_on_pipe(self.output_path.clone(), value).map_err(|e| format!("error writing: {}", e))
    }
}

impl Drop for CommunicationService{
    fn drop(&mut self) {
        match delete_pipes(self.input_path.to_owned(), self.output_path.to_owned()){
            Ok(()) => println!("pipes deleted"),
            Err(e) => eprintln!("error deleting pipes: {}", e)
        }
    }
}

#[cfg(test)]
mod tests{
    use std::fs::metadata;
    use std::thread;

    use super::{Command, CommunicationService, pipes::{write_on_pipe, read_from_pipe}};

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

    fn can_receive_input(s: &'static str, command: Command, number: i32) -> Result<(),String>{
        let service = CommunicationService::new_for_test(number);
        let input_path = service.input_path.to_owned();
        let child = thread::spawn(move ||{
            write_on_pipe(input_path, String::from(s))
        });
        match service.get_input(){
            Ok(c) if c == command => child.join().map_err(|e| format!("error joining: {:?}", e))?.map_err(|e|format!("error joining: {}", e)),
            Ok(s) => Err(format!("Wrong command: {:?}",s)),
            Err(e) => Err(e)
        }
    }

    #[test]
    fn can_receive_all_input() -> Result<(),String>{
        can_receive_input("GET", Command::Get, 2)?;
        can_receive_input("SET", Command::Set, 3)?;
        can_receive_input("PERFORMANCE", Command::Performance, 4)?;
        can_receive_input("BALANCED", Command::Balanced, 5)?;
        can_receive_input("SILENT", Command::Silent, 6)?;
        can_receive_input("BATTERY", Command::Battery, 7)?;
        can_receive_input("COOLER_BOOST", Command::CoolerBoost, 8)?;
        can_receive_input("CHARGING_LIMIT", Command::ChargingLimit, 9)?;
        can_receive_input("PROFILE", Command::Profile, 10)
    }

    #[test]
    fn can_write_output() -> Result<(), String>{
        let test = "abcefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        let service = CommunicationService::new_for_test(11);
        let output = service.output_path.clone();
        let child = thread::spawn(move ||{
            read_from_pipe(output)
        });
        service.write_output(test.to_string())?;
        match child.join().map_err(|e| format!("error joining: {:?}", e))?{
            Ok(s) if s == test => Ok(()),
            Ok(s) => Err(format!("result '{}' is different from expected '{}'", s, test)),
            Err(e) => Err(format!("error writing: {}", e))
        }
    }
}