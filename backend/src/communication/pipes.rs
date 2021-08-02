use std::fs::{File, OpenOptions};
use std::io::{Error, Read, Write};

use nix::unistd::mkfifo;
use nix::sys::stat::Mode;

fn create_pipe(path: &'static str) -> Result<(),String>{
    match mkfifo(path, Mode::S_IRWXU){
        Ok(()) => Ok(()),
        Err(e) => Err(format!("unable to create pipe {}", e))
    }
}

fn read_from_pipe(path: &'static str) -> std::io::Result<String>{
    let mut file = File::open(path)?;
    let mut result = String::new();
    let count = file.read_to_string(&mut result)?;
    if count==0 { 
        Err(Error::new(std::io::ErrorKind::BrokenPipe, "zero bytes read"))
    } else {Ok(result)}
}

fn write_on_pipe(path: &'static str, value: &'static str) -> std::io::Result<()>{
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
    use std::{fs::{self, metadata}, thread, time::Duration};
    use super::*;

    #[test]
    fn can_create() -> Result<(), String>{
        create_pipe("./test1_pipe")?;
        match metadata("./test1_pipe"){
            Ok(_data) => {
                fs::remove_file("./test1_pipe").map_err(|e| format!("error removing: {}", e))?;
                Ok(())
            },
            Err(e) => Err(format!("test failed {}", e))
        }
    }

    #[test]
    fn can_write_to_pipe() -> std::io::Result<()>{
        create_pipe("./test2_pipe").map_err(|e| Error::new(std::io::ErrorKind::BrokenPipe, e))?;
        Ok(write_on_pipe("./test2_pipe", "test")?)
    }

    #[test]
    fn can_read_from_pipe() -> std::io::Result<()>{
        thread::sleep(Duration::from_millis(500));
        let result = read_from_pipe("./test2_pipe").map_err(|e| Error::new(std::io::ErrorKind::BrokenPipe, e))?;
        fs::remove_file("./test2_pipe")?;
        if result == "test"{
            Ok(())
        } else{
            Err(Error::new(std::io::ErrorKind::BrokenPipe, "wrong result"))
        }
    }
}