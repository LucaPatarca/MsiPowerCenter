use std::{fmt::Error, fs::{read_dir}, io, path::Path};
use crate::{hwconfig::file_utils::*, model::{paths::Paths, profile::CpuConfig}};

pub struct CpuController {
    cpu_count: i32,
    max_freq: i32,
    min_freq: i32,
    available_governors: Vec<String>,
    available_energy_prefs: Vec<String>,
    paths: Paths
}

impl CpuController{
    pub fn new() -> Self{
        let paths = Paths::new_auto();
        let cpu_count = paths.cpuinfo_max_freq.len() as i32;
        let max_freq = read_file_as_int(&paths.cpuinfo_max_freq[0]).unwrap();
        let min_freq = read_file_as_int(&paths.cpuinfo_min_freq[0]).unwrap();
        let available_governors = read_file_as_string_list(&paths.scaling_available_governors[0]).unwrap();
        let available_energy_prefs = read_file_as_string_list(&paths.available_energy_prefs[0]).unwrap();
        Self{cpu_count,max_freq,min_freq,available_governors,available_energy_prefs, paths}
    }

    pub fn read_config(&self) -> Result<CpuConfig, io::Error>{
        let max_freq = read_file_as_int(&self.paths.scaling_max_freq[0])?;
        let min_freq = read_file_as_int(&self.paths.scaling_min_freq[0])?;
        let max_perf = read_file_as_int(&self.paths.pstate_max_perf)?;
        let min_perf = read_file_as_int(&self.paths.pstate_min_perf)?;
        let governor = read_file_as_string(&self.paths.scaling_governor[0])?;
        let energy_pref = read_file_as_string(&self.paths.energy_pref[0])?;
        let turbo = read_file_as_int(&self.paths.pstate_no_turbo)? == 0;
        Ok(CpuConfig{max_freq, min_freq,max_perf, min_perf, governor, turbo, energy_pref})
    }

    pub fn write_config(&self, config: CpuConfig) -> Result<(),io::Error>{if config.max_freq > self.max_freq ||
        config.min_freq < self.min_freq ||
        !self.available_governors.contains(&config.governor) ||
        !self.available_energy_prefs.contains(&config.energy_pref)||
        config.max_perf>100||
        config.max_perf<0 ||
        config.min_perf<0 ||
        config.min_perf>config.max_perf ||
        config.min_freq>config.max_freq ||
        config.max_freq<self.min_freq{
            return Err(io::Error::new(io::ErrorKind::Other, "Wrong configuration"))
        }
        for path in &self.paths.scaling_max_freq{
            write_file(path, config.max_freq.to_string())?;
        }
        for path in &self.paths.scaling_min_freq{
            write_file(path, config.min_freq.to_string())?;
        }
        for path in &self.paths.scaling_governor{
            write_file(path, config.governor.to_string())?;
        }
        for path in &self.paths.energy_pref{
            write_file(path, config.energy_pref.to_string())?;
        }
        write_file(&self.paths.pstate_max_perf, config.max_perf.to_string())?;
        write_file(&self.paths.pstate_min_perf, config.min_perf.to_string())?;
        let turbo = if config.turbo {0.to_string()} else {1.to_string()};
        write_file(&self.paths.pstate_no_turbo, turbo)?;
        Ok(())
    }
    
}

#[cfg(test)]
mod tests{
    use std::io::Error;

    use super::*;

    #[test]
    fn can_initialize_correctly(){
        let mut controller = CpuController::new();
        controller.paths = Paths::new_test();
        assert_eq!(controller.cpu_count, 8);
        assert_eq!(controller.max_freq, 4800000);
        assert_eq!(controller.min_freq, 400000);
        assert!(controller.available_energy_prefs.contains(&String::from("default")));
        assert!(controller.available_energy_prefs.contains(&String::from("performance")));
        assert!(controller.available_energy_prefs.contains(&String::from("balance_performance")));
        assert!(controller.available_energy_prefs.contains(&String::from("balance_power")));
        assert!(controller.available_energy_prefs.contains(&String::from("power")));
        assert!(controller.available_governors.contains(&String::from("performance")));
        assert!(controller.available_governors.contains(&String::from("powersave")));
    }

    #[test]
    fn can_read_config() -> Result<(), Error>{
        let mut controller = CpuController::new();
        controller.paths = Paths::new_test();
        let config = controller.read_config()?;
        assert_eq!(config.energy_pref, "balance_performance");
        assert_eq!(config.governor, "powersave");
        assert_eq!(config.max_freq, 4600000);
        assert_eq!(config.min_freq, 400000);
        assert_eq!(config.max_perf, 100);
        assert_eq!(config.min_perf, 8);
        assert_eq!(config.turbo, true);
        Ok(())
    }

    #[test]
    fn can_write_config() -> Result<(), Error>{
        let controller = CpuController::new();
        let mut config = CpuConfig{
            max_freq:3000000, 
            min_freq:400000, 
            max_perf: 80, 
            min_perf:8, 
            governor:"powersave".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        controller.write_config(config.to_owned())?;
        for path in &controller.paths.scaling_max_freq{
            assert_eq!(config.max_freq, read_file_as_int(&path)?);
        }
        for path in &controller.paths.scaling_min_freq{
            assert_eq!(config.min_freq, read_file_as_int(&path)?);
        }
        for path in &controller.paths.scaling_governor{
            assert_eq!(config.governor, read_file_as_string(&path)?);
        }
        for path in &controller.paths.energy_pref{
            assert_eq!(config.energy_pref, read_file_as_string(&path)?);
        }
        assert_eq!(config.max_perf, read_file_as_int(&controller.paths.pstate_max_perf)?);
        assert_eq!(config.min_perf, read_file_as_int(&controller.paths.pstate_min_perf)?);
        assert_eq!(config.turbo, read_file_as_int(&controller.paths.pstate_no_turbo)?==0);

        config = CpuConfig{
            max_freq:4600000, 
            min_freq:800000, 
            max_perf: 100, 
            min_perf:20, 
            governor:"performance".to_string(), 
            energy_pref:"balance_performance".to_string(), 
            turbo: true
        };
        controller.write_config(config.to_owned())?;
        for path in &controller.paths.scaling_max_freq{
            assert_eq!(config.max_freq, read_file_as_int(&path)?);
        }
        for path in &controller.paths.scaling_min_freq{
            assert_eq!(config.min_freq, read_file_as_int(&path)?);
        }
        for path in &controller.paths.scaling_governor{
            assert_eq!(config.governor, read_file_as_string(&path)?);
        }
        for path in &controller.paths.energy_pref{
            assert_eq!(config.energy_pref, read_file_as_string(&path)?);
        }
        assert_eq!(config.max_perf, read_file_as_int(&controller.paths.pstate_max_perf)?);
        assert_eq!(config.min_perf, read_file_as_int(&controller.paths.pstate_min_perf)?);
        assert_eq!(config.turbo, read_file_as_int(&controller.paths.pstate_no_turbo)?==0);

        config = CpuConfig{
            max_freq:3000000, 
            min_freq:400000, 
            max_perf: 80, 
            min_perf:8, 
            governor:"powersave".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        controller.write_config(config.to_owned())?;
        for path in controller.paths.scaling_max_freq{
            assert_eq!(config.max_freq, read_file_as_int(&path)?);
        }
        for path in controller.paths.scaling_min_freq{
            assert_eq!(config.min_freq, read_file_as_int(&path)?);
        }
        for path in controller.paths.scaling_governor{
            assert_eq!(config.governor, read_file_as_string(&path)?);
        }
        for path in controller.paths.energy_pref{
            assert_eq!(config.energy_pref, read_file_as_string(&path)?);
        }
        assert_eq!(config.max_perf, read_file_as_int(&controller.paths.pstate_max_perf)?);
        assert_eq!(config.min_perf, read_file_as_int(&controller.paths.pstate_min_perf)?);
        assert_eq!(config.turbo, read_file_as_int(&controller.paths.pstate_no_turbo)?==0);
        Ok(())
    }

    #[test]
    fn fails_on_write_wrong_config() {
        let controller = CpuController::new();
        let mut config = CpuConfig{
            max_freq:10000000, 
            min_freq:400000, 
            max_perf: 80, 
            min_perf:8, 
            governor:"powersave".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        assert!(controller.write_config(config).is_err());

        config = CpuConfig{
            max_freq:3000000, 
            min_freq:100000, 
            max_perf: 80, 
            min_perf:8, 
            governor:"powersave".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        assert!(controller.write_config(config).is_err());

        config = CpuConfig{
            max_freq:3000000, 
            min_freq:400000, 
            max_perf: 110, 
            min_perf:8, 
            governor:"powersave".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        assert!(controller.write_config(config).is_err());

        config = CpuConfig{
            max_freq:3000000, 
            min_freq:100000, 
            max_perf: 80, 
            min_perf: -1, 
            governor:"powersave".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        assert!(controller.write_config(config).is_err());

        config = CpuConfig{
            max_freq:3000000, 
            min_freq:100000, 
            max_perf: 80, 
            min_perf:8, 
            governor:"wrong".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        assert!(controller.write_config(config).is_err());

        config = CpuConfig{
            max_freq:3000000, 
            min_freq:100000, 
            max_perf: 80, 
            min_perf:8, 
            governor:"powersave".to_string(), 
            energy_pref:"wrong".to_string(), 
            turbo: true
        };
        assert!(controller.write_config(config).is_err());

        config = CpuConfig{
            max_freq:3000000, 
            min_freq:100000, 
            max_perf: -1, 
            min_perf:8, 
            governor:"powersave".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        assert!(controller.write_config(config).is_err());

        config = CpuConfig{
            max_freq:3000000, 
            min_freq:100000, 
            max_perf: 80, 
            min_perf:100, 
            governor:"powersave".to_string(), 
            energy_pref:"balance_power".to_string(), 
            turbo: true
        };
        assert!(controller.write_config(config).is_err());
    }
}