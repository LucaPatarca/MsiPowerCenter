use std::{fs::File, io::{Error, Read}};

pub fn read_file_as_string(path: String) -> Result<String, Error> {
    let mut file = File::open(path)?;
    let mut buf = String::new();
    let count = file.read_to_string(&mut buf)?;
    if count==0 {
        Err(Error::new(std::io::ErrorKind::Other, "readed zero bytes"))
    } else{
        if buf.ends_with("\n") {
            buf.pop();
        }
        Ok(buf)
    }
}

pub fn read_file_as_int(path: String) -> Result<i32, Error> {
    let string = read_file_as_string(path)?;
    match string.parse(){
        Ok(i) => Ok(i),
        Err(e) => Err(Error::new(std::io::ErrorKind::Other, format!("parsing error: {}",e)))
    }
}

pub fn read_file_as_string_list(path: String) -> Result<Vec<String>, Error>{
    let string = read_file_as_string(path)?;
    let split = string.split(" ");
    let mut result = Vec::new();
    for element in split{
        let string_element = String::from(element);
        result.push(string_element);
    }
    Ok(result)
}

#[cfg(test)]
mod tests{
    use std::io::Error;
    use super::*;

    #[test]
    fn can_read_file_as_string() -> Result<(), Error>{
        let result = read_file_as_string(String::from("test_files/test_read_string"))?;
        if result == "abcefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"{
            Ok(())
        }else{
            Err(Error::new(std::io::ErrorKind::Other, format!("wrong output '{}'", result)))
        }
    }

    #[test]
    fn can_read_file_as_int() -> Result<(), Error>{
        let result = read_file_as_int("test_files/test_read_int_pass".to_string())?;
        assert_eq!(result, 1234567890);
        match read_file_as_int("test_files/test_read_int_fail".to_string()) {
            Ok(i) => Err(Error::new(std::io::ErrorKind::Other, format!("should have failed, instead returned: {}", i))), 
            Err(_e) => Ok(())
        }
    }

    #[test]
    fn can_read_file_as_list() -> Result<(), Error>{
        let result = read_file_as_string_list("test_files/test_read_list".to_string())?;
        match result.len() {
            4 => 
                if result.contains(&String::from("element1")) &&
                    result.contains(&String::from("element2")) &&
                    result.contains(&String::from("element3"))&&
                    result.contains(&String::from("element4")){
                    Ok(())
                }else{ return Err(Error::new(std::io::ErrorKind::Other, "does not contain one or more element"));},
            n => Err(Error::new(std::io::ErrorKind::Other, format!("wrong size: {}",n)))
        }
    }
}