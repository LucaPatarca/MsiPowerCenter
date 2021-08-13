use std::fs::read_dir;

use ini::Ini;

use crate::model::profile::{CpuConfig, EcConfig, Profile};

#[cfg(test)]
const PROFILES_PATH: &'static str = "test_files/profiles";
#[cfg(not(test))]
const PROFILES_PATH: &'static str = "/opt/MsiPowerCenter/profiles/";

#[derive(Clone)]
pub struct AvailableProfiles{
    profiles: Vec<Profile>,
    cur: usize
}

impl AvailableProfiles{
    pub fn load() -> Self{
        let mut profiles = Vec::new();
        if let Ok(entries) = read_dir(PROFILES_PATH) {
            for entry_result in entries{
                if entry_result.is_ok() {
                    let path = entry_result.unwrap().path();
                    if let Ok(ini) = Ini::load_from_file(path){
                        if let Ok(profile) = Profile::from_ini(&ini){
                            profiles.push(profile);
                        }
                    }
                }
            }
        } 
        AvailableProfiles{profiles, cur: 0}
    }

    pub fn get<'g>(&self, index: &'g str)->Option<Profile>{
        for profile in self.profiles.clone(){
            if profile.name == index{
                return Some(profile);
            }
        }
        None
    }

    pub fn find_name(&self, cpu: CpuConfig, ec: EcConfig) -> String{
        match self.profiles.iter().find(|p|p.cpu == cpu && p.ec == ec){
            Some(p) => p.name.clone(),
            None => String::from("current"),
        }
    }
}

impl Iterator for AvailableProfiles{
    type Item = Profile;

    fn next(&mut self) -> Option<Self::Item> {
        let cur = self.cur;
        if self.cur < self.profiles.len() {
            self.cur+=1;
            let profile = self.profiles.get(cur)?.clone();
            Some(profile)
        } else {
            self.cur = 0;
            None
        }
    }
}

#[cfg(test)]
mod tests{
    use super::*;

    #[test]
    fn can_initialize_correctly(){
        let profiles = AvailableProfiles::load();
        assert_eq!(profiles.profiles.len(), 3);
        assert!(profiles.get("Balanced").is_some());
        assert!(profiles.get("Performance").is_some());
        assert!(profiles.get("Battery").is_some());
    }

    #[test]
    fn can_iterate(){
        let profiles = AvailableProfiles::load();
        for profile in profiles{
            assert!(!profile.name.is_empty());
        }
    }
}