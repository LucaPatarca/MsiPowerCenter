use std::fs::{self, OpenOptions};
use std::io::{Error, Read, Write};
use std::os::unix::prelude::PermissionsExt;

use close_file::Closable;
use nix::unistd::mkfifo;
use nix::sys::stat::Mode;

fn create_pipe(path: String, mode: Mode) -> Result<(),String>{
    match mkfifo(path.as_str(), mode){
        Ok(()) => Ok(()),
        Err(e) => Err(format!("unable to create pipe {}", e))
    }
}

pub fn create_pipes(input_path: String, output_path: String, realtime_path: String) -> Result<(), String>{
    create_pipe(input_path.to_owned(), Mode::S_IRWXU | Mode::S_IRWXG | Mode::S_IRWXO)?;
    fs::set_permissions(input_path, PermissionsExt::from_mode(0o666)).map_err(|e|format!("Error setting permissions: {}",e))?;
    create_pipe(output_path.to_owned(), Mode::S_IRWXU | Mode::S_IRWXG | Mode::S_IRWXO)?;
    fs::set_permissions(output_path, PermissionsExt::from_mode(0o666)).map_err(|e|format!("Error setting permissions: {}",e))?;
    create_pipe(realtime_path.to_owned(), Mode::S_IRWXU | Mode::S_IRWXG | Mode::S_IRWXO)?;
    fs::set_permissions(realtime_path, PermissionsExt::from_mode(0o666)).map_err(|e|format!("Error setting permissions: {}",e))?;
    Ok(())
}

pub fn delete_pipes(input_path: String, output_path: String, realtime_path: String) -> std::io::Result<()>{
    fs::remove_file(input_path)?;
    fs::remove_file(output_path)?;
    fs::remove_file(realtime_path)
}

pub fn read_from_pipe(path: String) -> std::io::Result<String>{
    let mut file = OpenOptions::new().read(true).write(false).append(false).open(path)?;
    let mut result = String::new();
    file.read_to_string(&mut result)?;
    Ok(result)
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

    #[test]
    fn can_write_and_read_pipe() -> std::io::Result<()>{
        let path = String::from("./test2_pipe");
        let path_thread = path.clone();
        create_pipe(path.to_owned(), Mode::S_IRWXU).map_err(|e| Error::new(std::io::ErrorKind::BrokenPipe, e))?;
        let child = thread::spawn(move ||{
            write_on_pipe(path_thread, "ABCDEFG".to_string())
        });
        let result = read_from_pipe(path.to_owned()).map_err(|e| Error::new(std::io::ErrorKind::BrokenPipe, e))?;
        child.join().map_err(|_e|  Error::new(std::io::ErrorKind::BrokenPipe, "Error joining"))??;
        fs::remove_file(path)?;
        if result == "ABCDEFG"{
            Ok(())
        } else{
            Err(Error::new(std::io::ErrorKind::BrokenPipe, "wrong result"))
        }
    }
}