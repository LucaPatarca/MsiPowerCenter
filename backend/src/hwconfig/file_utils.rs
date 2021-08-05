use std::{fs::{File, OpenOptions}, io::{Error, Read, Seek, SeekFrom, Write}, path::{Path}};

pub fn read_file_as_string(path: &Path) -> Result<String, Error> {
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

pub fn read_file_as_int(path: &Path) -> Result<i32, Error> {
    let string = read_file_as_string(path)?;
    match string.parse(){
        Ok(i) => Ok(i),
        Err(e) => Err(Error::new(std::io::ErrorKind::Other, format!("parsing error: {}",e)))
    }
}

pub fn read_file_as_string_list(path: &Path) -> Result<Vec<String>, Error>{
    let string = read_file_as_string(path)?;
    let split = string.split(" ");
    let mut result = Vec::new();
    for element in split{
        let string_element = String::from(element);
        result.push(string_element);
    }
    Ok(result)
}

pub fn write_file(path: &Path, value: String) -> Result<(),Error>{
    let mut file = OpenOptions::new().read(false).write(true).truncate(true).open(path)?;
    let count = file.write(value.as_bytes())?;
    if count != value.len(){
        Err(Error::new(std::io::ErrorKind::Other, "partial write"))
    } else {
        Ok(())
    }
}

pub fn write_ec(path: &Path, address: i64, value: u8) -> Result<(),Error>{
    let mut file = OpenOptions::new().read(false).write(true).truncate(false).open(path)?;
    file.seek(SeekFrom::Current(address))?;
    let count = file.write(&[value])?;
    if count != 1 { Err(Error::new(std::io::ErrorKind::Other, "no byte write"))}
    else {Ok(())}
}

pub fn read_ec(path: &Path, address: i64) -> Result<u8, Error>{
    let mut file = File::open(path)?;
    file.seek(SeekFrom::Current(address))?;
    let mut result = [0u8];
    let count = file.read(&mut result)?;
    if count != 1 { Err(Error::new(std::io::ErrorKind::Other, "no byte read"))}
    else {Ok(result[0])}
}

#[cfg(test)]
mod tests{
    use std::{fs, io::Error};
    use super::*;

    #[test]
    fn can_read_file_as_string() -> Result<(), Error>{
        let result = read_file_as_string(Path::new("test_files/test_read_string"))?;
        if result == "abcefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"{
            Ok(())
        }else{
            Err(Error::new(std::io::ErrorKind::Other, format!("wrong output '{}'", result)))
        }
    }

    #[test]
    fn can_read_file_as_int() -> Result<(), Error>{
        let result = read_file_as_int(Path::new("test_files/test_read_int_pass"))?;
        assert_eq!(result, 1234567890);
        match read_file_as_int(Path::new("test_files/test_read_int_fail")) {
            Ok(i) => Err(Error::new(std::io::ErrorKind::Other, format!("should have failed, instead returned: {}", i))), 
            Err(_e) => Ok(())
        }
    }

    #[test]
    fn can_read_file_as_list() -> Result<(), Error>{
        let result = read_file_as_string_list(Path::new("test_files/test_read_list"))?;
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

    #[test]
    fn can_write_file() -> Result<(),Error>{
        File::create("test_files/test_write")?;
        write_file(Path::new("test_files/test_write"), "abcdefg".to_string())?;
        let result1 = read_file_as_string(Path::new("test_files/test_write"))?;
        assert_eq!(result1, "abcdefg");
        write_file(Path::new("test_files/test_write"), "1234567890".to_string())?;
        let result2 = read_file_as_int(Path::new("test_files/test_write"))?;
        assert_eq!(result2, 1234567890);
        write_file(Path::new("test_files/test_write"), "abcdefg".to_string())?;
        let result1 = read_file_as_string(Path::new("test_files/test_write"))?;
        assert_eq!(result1, "abcdefg");
        fs::remove_file("test_files/test_write")?;
        Ok(())
    }

    #[test]
    fn can_read_ec() -> Result<(),Error>{
        assert_eq!(read_ec(Path::new("test_files/io"), 0x6a)?, 0x32);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x6b)?, 0x3a);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x6c)?, 0x41);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x6d)?, 0x46);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x6e)?, 0x5a);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x6f)?, 0x5f);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x70)?, 0x64);

        assert_eq!(read_ec(Path::new("test_files/io"), 0x72)?, 0x2d);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x73)?, 0x3a);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x74)?, 0x41);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x75)?, 0x48);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x76)?, 0x50);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x77)?, 0x55);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x78)?, 0x64);

        assert_eq!(read_ec(Path::new("test_files/io"), 0x82)?, 0x32);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x83)?, 0x3c);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x84)?, 0x46);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x85)?, 0x52);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x86)?, 0x5a);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x87)?, 0x5d);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x88)?, 0x64);

        assert_eq!(read_ec(Path::new("test_files/io"), 0x8a)?, 0x2d);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x8b)?, 0x32);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x8c)?, 0x41);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x8d)?, 0x48);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x8e)?, 0x50);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x8f)?, 0x55);
        assert_eq!(read_ec(Path::new("test_files/io"), 0x90)?, 0x64);
        Ok(())
    }

    #[test]
    fn can_write_ec() -> Result<(),Error>{
        write_ec(Path::new("../mockFiles/io"), 0x6d, 0x71)?;
        write_ec(Path::new("../mockFiles/io"), 0x75, 0x23)?;
        write_ec(Path::new("../mockFiles/io"), 0x85, 0x59)?;
        write_ec(Path::new("../mockFiles/io"), 0x8d, 0x02)?;

        assert_eq!(read_ec(Path::new("../mockFiles/io"), 0x6d)?, 0x71);
        assert_eq!(read_ec(Path::new("../mockFiles/io"), 0x75)?, 0x23);
        assert_eq!(read_ec(Path::new("../mockFiles/io"), 0x85)?, 0x59);
        assert_eq!(read_ec(Path::new("../mockFiles/io"), 0x8d)?, 0x02);

        write_ec(Path::new("../mockFiles/io"), 0x6d, 0x46)?;
        write_ec(Path::new("../mockFiles/io"), 0x75, 0x48)?;
        write_ec(Path::new("../mockFiles/io"), 0x85, 0x52)?;
        write_ec(Path::new("../mockFiles/io"), 0x8d, 0x48)?;

        assert_eq!(read_ec(Path::new("../mockFiles/io"), 0x6d)?, 0x46);
        assert_eq!(read_ec(Path::new("../mockFiles/io"), 0x75)?, 0x48);
        assert_eq!(read_ec(Path::new("../mockFiles/io"), 0x85)?, 0x52);
        assert_eq!(read_ec(Path::new("../mockFiles/io"), 0x8d)?, 0x48);
        Ok(())
    }
}