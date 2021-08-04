use crate::model::profile::Profile;

use self::{cpu_controller::CpuController, ec_controller::EcController};

mod cpu_controller;
mod file_utils;
mod ec_controller;

pub struct ProfileController{
    cpu_controller: CpuController,
    ec_controller: EcController,
}

impl ProfileController{
    pub fn new() -> Self{
        Self{
            cpu_controller: CpuController::new(),
            ec_controller: EcController::new()
        }
    }

    pub fn apply_profile(&self,profile: Profile) -> Result<(), String>{
        self.cpu_controller.write_config(profile.cpu).map_err(|e| format!("Error writing cpu config: {}",e))?;
        self.ec_controller.write_config(profile.ec).map_err(|e| format!("Error writing ec config: {}",e))
    }

    pub fn read_profile(&self) -> Result<Profile, String>{
        let cpu = self.cpu_controller.read_config().map_err(|e|format!("Error reading cpu config: {}", e))?;
        let ec = self.ec_controller.read_config().map_err(|e|format!("Error reading ec config: {}", e))?;
        Ok(Profile{name: String::from("current"), cpu, ec})
    }
}