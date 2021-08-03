use std::fs::{self, File, OpenOptions};
use std::io::{Error, Read, Write};

use nix::unistd::mkfifo;
use nix::sys::stat::Mode;

fn create_pipe(path: String, mode: Mode) -> Result<(),String>{
    match mkfifo(path.as_str(), mode){
        Ok(()) => Ok(()),
        Err(e) => Err(format!("unable to create pipe {}", e))
    }
}

pub fn create_pipes(input_path: String, output_path: String) -> Result<(), String>{
    create_pipe(input_path, Mode::S_IRWXU)?;
    create_pipe(output_path, Mode::S_IRWXU)
}

pub fn delete_pipes(input_path: String, output_path: String) -> std::io::Result<()>{
    fs::remove_file(input_path)?;
    fs::remove_file(output_path)
}

pub fn read_from_pipe(path: String) -> std::io::Result<String>{
    let mut file = File::open(path)?;
    let mut result = String::new();
    let count = file.read_to_string(&mut result)?;
    if count==0 { 
        Err(Error::new(std::io::ErrorKind::BrokenPipe, "zero bytes read"))
    } else {Ok(result)}
}

pub fn write_on_pipe(path: String, value: String) -> std::io::Result<()>{
    let mut file = OpenOptions::new().read(false).write(true).append(false).open(path)?;
    let count = file.write(value.as_bytes())?;
    if count == 0 {
        Err(Error::new(std::io::ErrorKind::BrokenPipe, "zero bytes writen"))
    } else {
        Ok(())
    }
}

#[cfg(test)]
mod tests{
    use std::{fs::{self, metadata}, thread};
    use super::*;

    #[test]
    fn can_create() -> Result<(), String>{
        let path = String::from("./test1_pipe");
        create_pipe(path.to_owned(), Mode::S_IRWXU)?;
        match metadata(path.to_owned()){
            Ok(_data) => {
                fs::remove_file(path.to_owned()).map_err(|e| format!("error removing: {}", e))?;
                Ok(())
            },
            Err(e) => Err(format!("test failed {}", e))
        }
    }

    //TODO unire i test di read e write in un unica funzione che spowna 2 thread diversi in modo da evitare che sia necessaria l'attesa del read
    #[test]
    fn can_write_and_read_pipe() -> std::io::Result<()>{
        let path = String::from("./test2_pipe");
        let path_thread = path.clone();
        create_pipe(path.to_owned(), Mode::S_IRWXU).map_err(|e| Error::new(std::io::ErrorKind::BrokenPipe, e))?;
        let child = thread::spawn(move ||{
            write_on_pipe(path_thread, String::from("test"))
        });
        let result = read_from_pipe(path.to_owned()).map_err(|e| Error::new(std::io::ErrorKind::BrokenPipe, e))?;
        child.join().map_err(|_e|  Error::new(std::io::ErrorKind::BrokenPipe, "Error joining"))??;
        fs::remove_file(path)?;
        if result == "test"{
            Ok(())
        } else{
            Err(Error::new(std::io::ErrorKind::BrokenPipe, "wrong result"))
        }
    }
}