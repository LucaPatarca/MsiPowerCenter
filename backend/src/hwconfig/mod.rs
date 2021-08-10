use crate::{model::profile::Profile, profile::AvailableProfiles};

use self::{cpu_controller::CpuController, ec_controller::EcController};

mod cpu_controller;
mod file_utils;
mod ec_controller;

pub struct ProfileController{
    cpu_controller: CpuController,
    ec_controller: EcController,
    available_profofiles: AvailableProfiles
}

impl ProfileController{
    pub fn new() -> Self{
        Self{
            cpu_controller: CpuController::new(),
            ec_controller: EcController::new(),
            available_profofiles: AvailableProfiles::load()
        }
    }

    pub fn apply_profile<'a>(&self,name: &'a str) -> Result<(), String>{
        let profile = self.available_profofiles.get(name).ok_or(format!("no profile found for name: {}",name))?;
        self.cpu_controller.write_config(profile.cpu).map_err(|e| format!("Error writing cpu config: {}",e))?;
        self.ec_controller.write_config(profile.ec).map_err(|e| format!("Error writing ec config: {}",e))
    }

    pub fn set_cooler_boost(&self,value: bool) -> Result<(), String>{
        self.ec_controller.set_cooler_boost(value).map_err(|e|e.to_string())
    }

    pub fn set_charging_limit(&self, value: u8) -> Result<(), String>{
        self.ec_controller.set_charging_limit(value).map_err(|e|e.to_string())
    }

    pub fn read_profile(&self) -> Result<Profile, String>{
        let cpu = self.cpu_controller.read_config().map_err(|e|format!("Error reading cpu config: {}", e))?;
        let ec = self.ec_controller.read_config().map_err(|e|format!("Error reading ec config: {}", e))?;
        Ok(Profile{name: self.available_profofiles.find_name(cpu.to_owned(), ec.to_owned()), cpu, ec})
    }

    pub fn is_cooler_boost_enabled(&self) -> Result<bool, String>{
        self.ec_controller.is_cooler_boost_enabled().map_err(|e|e.to_string())
    }

    pub fn get_charging_limit(&self) -> Result<u8, String>{
        self.ec_controller.get_charging_limit().map_err(|e|e.to_string())
    }

    pub fn get_available_profiles(&self) -> Vec<String>{
        self.available_profofiles.to_owned().map(|e|e.name).collect()
    }
}

#[cfg(test)]
mod tests{

    use super::*;

    #[test]
    fn can_initialize_correctly(){
        let controller = ProfileController::new();
        assert_eq!(controller.get_available_profiles().len(), 3);
    }

    #[test]
    fn can_apply_and_read_profile() -> Result<(),String>{
        let controller = ProfileController::new();
        assert!(controller.get_available_profiles().contains(&"Balanced".to_string()));
        controller.apply_profile("Balanced")?;
        let result = controller.read_profile()?;
        assert_eq!(result.name, "Balanced");

        assert!(controller.get_available_profiles().contains(&"Battery".to_string()));
        controller.apply_profile("Battery")?;
        let result = controller.read_profile()?;
        assert_eq!(result.name, "Battery");
        Ok(())
    }
}