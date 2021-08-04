use std::{io, path::{Path, PathBuf}};

use crate::{controller::file_utils::write_ec, model::profile::{EcConfig, FanConfig}};

use super::file_utils::read_ec;

const CPU_TEMP_START            : i32 = 0x6A;
const GPU_TEMP_START            : i32 = 0x82;
const REALTIME_CPU_TEMP         : i32 = 0x68;
const REALTIME_GPU_TEMP         : i32 = 0x80;
const CPU_FAN_START             : i32 = 0x72;
const GPU_FAN_START             : i32 = 0x8A;
const REALTIME_CPU_FAN_SPEED    : i32 = 0x71;
const REALTIME_GPU_FAN_SPEED    : i32 = 0x89;
const COOLER_BOOST_ADDR         : i32 = 0x98;
const CHARGING_THRESHOLD_ADDR   : i32 = 0xEF;
const FAN_MODE_ADDR             : i32 = 0xF4;
const COOLER_BOOST_ON           : u8 = 0x80;
const COOLER_BOOST_OFF          : u8 = 0x00;

pub struct EcController{
    path: PathBuf
}

impl EcController{
    pub fn new() -> Self{
        let path;
        if cfg!(test) {
            path = Path::new("test_files/io");
        } else if cfg!(debug_assertions){
            path = Path::new("../mockFiles/io");
        } else {
            path = Path::new("/sys/kernel/debug/ec/ec0/io");
        }
        Self{path: path.to_path_buf()}
    }

    pub fn read_config(&self) -> Result<EcConfig, io::Error>{
        let mut cpu_fan_config = Vec::new();
        let mut gpu_fan_config = Vec::new();
        for offset in 0..7{
            cpu_fan_config.push(FanConfig{
                temp: read_ec(&self.path, (CPU_TEMP_START + offset).into())?,
                speed: read_ec(&self.path, (CPU_FAN_START + offset).into())?
            });
            gpu_fan_config.push(FanConfig{
                temp: read_ec(&self.path, (GPU_TEMP_START + offset).into())?,
                speed: read_ec(&self.path, (GPU_FAN_START + offset).into())?
            });
        }
        let cooler_boost = read_ec(&self.path, COOLER_BOOST_ADDR.into())? >=0x80;
        Ok(EcConfig{
            cooler_boost,
            cpu_fan_config,
            gpu_fan_config
        })
    }

    pub fn write_config(&self, config: EcConfig) -> Result<(), io::Error>{
        for offset in 0..7{
            let cpu_fan_config = config.cpu_fan_config.get(offset).unwrap_or(&FanConfig{temp: 0, speed: 0}).to_owned();
            write_ec(&self.path, (CPU_FAN_START + offset as i32).into(), cpu_fan_config.speed)?;
            write_ec(&self.path, (CPU_TEMP_START + offset as i32).into(), cpu_fan_config.temp)?;

            let gpu_fan_config = config.gpu_fan_config.get(offset).unwrap_or(&FanConfig{temp: 0, speed: 0}).to_owned();
            write_ec(&self.path, (GPU_FAN_START + offset as i32).into(), gpu_fan_config.speed)?;
            write_ec(&self.path, (GPU_TEMP_START + offset as i32).into(), gpu_fan_config.temp)?;
        }
        let cooler_boost = if config.cooler_boost {COOLER_BOOST_ON} else {COOLER_BOOST_OFF}; 
        write_ec(&self.path, COOLER_BOOST_ADDR.into(), cooler_boost)
    }

    pub fn is_cooler_boost_enabled(&self) -> Result<bool, io::Error>{
        let cooler_boost = read_ec(&self.path, COOLER_BOOST_ADDR.into())?;
        Ok(cooler_boost >= COOLER_BOOST_ON)
    }

    pub fn set_cooler_boost(&self, value: bool) -> Result<(), io::Error>{
        let cooler_boost = if value {COOLER_BOOST_ON} else {COOLER_BOOST_OFF};
        write_ec(&self.path, COOLER_BOOST_ADDR.into(), cooler_boost)
    }

    pub fn get_charging_limit(&self) -> Result<u8, io::Error>{
        let charging_limit = read_ec(&self.path, CHARGING_THRESHOLD_ADDR.into())?;
        Ok(charging_limit)
    }

    pub fn set_charging_limit(&self, value: u8) -> Result<(), io::Error>{
        if value > 100 || value < 30{
            return Err(io::Error::new(io::ErrorKind::Other, "invalid value"));
        }
        write_ec(&self.path, CHARGING_THRESHOLD_ADDR.into(), value)
    }
}

#[cfg(test)]
mod tests{
    use std::io::Error;

    use crate::model::profile::{EcConfig, FanConfig};

    use super::*;

    #[test]
    fn can_initialize_correctly(){
        let controller = EcController::new();
        assert_eq!(controller.path.as_path().to_string_lossy().to_string(), "test_files/io");
    }

    #[test]
    fn can_read_config() -> Result<(), Error>{
        let controller = EcController::new();
        let config = controller.read_config()?;
        let expected = EcConfig{
            cpu_fan_config: vec![
                FanConfig{speed: 0x2d, temp: 0x32 },
                FanConfig{speed: 0x3a, temp: 0x3a },
                FanConfig{speed: 0x41, temp: 0x41 },
                FanConfig{speed: 0x48, temp: 0x46 },
                FanConfig{speed: 0x50, temp: 0x5a },
                FanConfig{speed: 0x55, temp: 0x5f },
                FanConfig{speed: 0x64, temp: 0x64 },
            ],
            gpu_fan_config: vec![
                FanConfig{speed: 0x2d, temp: 0x32 },
                FanConfig{speed: 0x32, temp: 0x3c },
                FanConfig{speed: 0x41, temp: 0x46 },
                FanConfig{speed: 0x48, temp: 0x52 },
                FanConfig{speed: 0x50, temp: 0x5a },
                FanConfig{speed: 0x55, temp: 0x5d },
                FanConfig{speed: 0x64, temp: 0x64 },
            ],
            cooler_boost: false
        };
        assert_eq!(config,expected);
        Ok(())
    }

    #[test]
    fn can_write_config() -> Result<(), Error>{
        let mut controller = EcController::new();
        controller.path = Path::new("../mockFiles/io").to_path_buf();
        let balanced = EcConfig{
            cpu_fan_config: vec![
                FanConfig{speed: 45, temp: 50 },
                FanConfig{speed: 58, temp: 58 },
                FanConfig{speed: 65, temp: 65 },
                FanConfig{speed: 72, temp: 70 },
                FanConfig{speed: 80, temp: 90 },
                FanConfig{speed: 85, temp: 95 },
                FanConfig{speed: 100, temp: 100 },
            ],
            gpu_fan_config: vec![
                FanConfig{speed: 45, temp: 50 },
                FanConfig{speed: 50, temp: 60 },
                FanConfig{speed: 65, temp: 70 },
                FanConfig{speed: 72, temp: 82 },
                FanConfig{speed: 80, temp: 90 },
                FanConfig{speed: 85, temp: 93 },
                FanConfig{speed: 100, temp: 100 },
            ],
            cooler_boost: false
        };
        let battery = EcConfig{
            cpu_fan_config: vec![
                FanConfig{speed: 0, temp: 47 },
                FanConfig{speed: 16, temp: 53 },
                FanConfig{speed: 62, temp: 67 },
                FanConfig{speed: 69, temp: 80 },
                FanConfig{speed: 76, temp: 90 },
                FanConfig{speed: 84, temp: 95 },
                FanConfig{speed: 91, temp: 100 },
            ],
            gpu_fan_config: vec![
                FanConfig{speed: 0, temp: 55 },
                FanConfig{speed: 59, temp: 65 },
                FanConfig{speed: 70, temp: 75 },
                FanConfig{speed: 84, temp: 85 },
                FanConfig{speed: 91, temp: 90 },
                FanConfig{speed: 91, temp: 93 },
                FanConfig{speed: 91, temp: 100 },
            ],
            cooler_boost: false
        };
        controller.write_config(balanced.to_owned())?;
        let mut config = controller.read_config()?;
        assert_eq!(config, balanced);
        controller.write_config(battery.to_owned())?;
        config = controller.read_config()?;
        assert_eq!(config, battery);
        Ok(())
    }

    #[test]
    fn can_read_and_write_cooler_boost() -> Result<(), io::Error>{
        let mut controller = EcController::new();
        controller.path = Path::new("../mockFiles/io").to_path_buf();
        controller.set_cooler_boost(false)?;
        assert!(!controller.is_cooler_boost_enabled()?);
        controller.set_cooler_boost(true)?;
        assert!(controller.is_cooler_boost_enabled()?);
        Ok(())
    }

    #[test]
    fn can_read_and_write_charging_limit() -> Result<(), io::Error>{
        let mut controller = EcController::new();
        controller.path = Path::new("../mockFiles/io").to_path_buf();
        controller.set_charging_limit(80)?;
        assert_eq!(controller.get_charging_limit()?, 80);
        controller.set_charging_limit(60)?;
        assert_eq!(controller.get_charging_limit()?, 60);
        assert!(controller.set_charging_limit(10).is_err());
        assert!(controller.set_charging_limit(110).is_err());
        Ok(())
    }
}