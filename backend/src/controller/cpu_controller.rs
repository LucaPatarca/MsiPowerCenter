use std::{io, fs::{read_dir}, path::Path};
use crate::{controller::file_utils::*, model::{paths::Paths, profile::CpuConfig}};

#[cfg(not(any(debug_assertions, test)))]
const PATHS: Paths = Paths{
    pstate_max_perf: "/sys/devices/system/cpu/intel_pstate/max_perf_pct",
    pstate_min_perf: "/sys/devices/system/cpu/intel_pstate/min_perf_pct",
    pstate_no_turbo: "/sys/devices/system/cpu/intel_pstate/no_turbo",
    cpufreq_base_path: "/sys/devices/system/cpu/",
    scaling_max_freq: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq",
    scaling_min_freq: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq",
    scaling_governor: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor",
    cpuinfo_max_freq: "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq",
    cpuinfo_min_freq: "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq",
    scaling_available_governors: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors",
    energy_pref: "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference",
    available_energy_prefs: "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences"
};

#[cfg(all(not(test),debug_assertions))]
const PATHS: Paths = Paths{
    pstate_max_perf: "/home/luca/MsiPowerCenter/mockFiles/intel_pstate/max_perf_pct",
    pstate_min_perf: "/home/luca/MsiPowerCenter/mockFiles/intel_pstate/min_perf_pct",
    pstate_no_turbo: "/home/luca/MsiPowerCenter/mockFiles/intel_pstate/no_turbo",
    cpufreq_base_path: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/",
    scaling_max_freq: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/cpu0/cpufreq/scaling_max_freq",
    scaling_min_freq: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/cpu0/cpufreq/scaling_min_freq",
    scaling_governor: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/cpu0/cpufreq/scaling_governor",
    cpuinfo_max_freq: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/cpu0/cpufreq/cpuinfo_max_freq",
    cpuinfo_min_freq: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/cpu0/cpufreq/cpuinfo_min_freq",
    scaling_available_governors: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/cpu0/cpufreq/scaling_available_governors",
    energy_pref: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/cpu0/cpufreq/energy_performance_preference",
    available_energy_prefs: "/home/luca/MsiPowerCenter/mockFiles/cpufreq/cpu0/cpufreq/energy_performance_available_preferences"
};

#[cfg(all(debug_assertions, test))]
const PATHS: Paths = Paths{
    pstate_max_perf: "test_files/mockFiles/intel_pstate/max_perf_pct",
    pstate_min_perf: "test_files/mockFiles/intel_pstate/min_perf_pct",
    pstate_no_turbo: "test_files/mockFiles/intel_pstate/no_turbo",
    cpufreq_base_path: "test_files/mockFiles/cpufreq/",
    scaling_max_freq: "test_files/mockFiles/cpufreq/cpu0/cpufreq/scaling_max_freq",
    scaling_min_freq: "test_files/mockFiles/cpufreq/cpu0/cpufreq/scaling_min_freq",
    scaling_governor: "test_files/mockFiles/cpufreq/cpu0/cpufreq/scaling_governor",
    cpuinfo_max_freq: "test_files/mockFiles/cpufreq/cpu0/cpufreq/cpuinfo_max_freq",
    cpuinfo_min_freq: "test_files/mockFiles/cpufreq/cpu0/cpufreq/cpuinfo_min_freq",
    scaling_available_governors: "test_files/mockFiles/cpufreq/cpu0/cpufreq/scaling_available_governors",
    energy_pref: "test_files/mockFiles/cpufreq/cpu0/cpufreq/energy_performance_preference",
    available_energy_prefs: "test_files/mockFiles/cpufreq/cpu0/cpufreq/energy_performance_available_preferences"
};

pub struct CpuController {
    cpu_count: i32,
    max_freq: i32,
    min_freq: i32,
    available_governors: Vec<String>,
    available_energy_prefs: Vec<String>
}

impl CpuController{
    pub fn new() -> Self{
        let cpu_count = Self::get_cpu_count();
        let max_freq = read_file_as_int(PATHS.cpuinfo_max_freq.to_string()).unwrap();
        let min_freq = read_file_as_int(PATHS.cpuinfo_min_freq.to_string()).unwrap();
        let available_governors = read_file_as_string_list(PATHS.scaling_available_governors.to_string()).unwrap();
        let available_energy_prefs = read_file_as_string_list(PATHS.available_energy_prefs.to_string()).unwrap();
        Self{cpu_count,max_freq,min_freq,available_governors,available_energy_prefs}
    }

    pub fn read_config(&self) -> Result<CpuConfig, io::Error>{
        let max_freq = read_file_as_int(PATHS.scaling_max_freq.to_string())?;
        let min_freq = read_file_as_int(PATHS.scaling_min_freq.to_string())?;
        let max_perf = read_file_as_int(PATHS.pstate_max_perf.to_string())?;
        let min_perf = read_file_as_int(PATHS.pstate_min_perf.to_string())?;
        let governor = read_file_as_string(PATHS.scaling_governor.to_string())?;
        let energy_pref = read_file_as_string(PATHS.energy_pref.to_string())?;
        let turbo = read_file_as_int(PATHS.pstate_no_turbo.to_string())? == 0;
        Ok(CpuConfig{max_freq, min_freq,max_perf, min_perf, governor, turbo, energy_pref})
    }
    
    fn get_cpu_count() -> i32{
        let count = read_dir(Path::new(PATHS.cpufreq_base_path)).unwrap().filter(|entry| {
            let name = entry.as_ref().unwrap().file_name();
            let string_name = name.to_string_lossy().to_string();
            let mut name_chars = string_name.chars();
            match name_chars.next() {
                Some(c1) if c1 =='c' => match name_chars.next() {
                    Some(c2) if c2 == 'p' => match name_chars.next() {
                        Some(c3) if c3 == 'u' => match name_chars.next() {
                            Some(c4) if c4.is_ascii_digit() => true,
                            _ => false
                        },
                        _ => false
                    },
                    _ => false
                },
                _ => false 
            }
        }).count();
        count as i32
    }
    
}

#[cfg(test)]
mod tests{
    use std::io::Error;

    use super::*;

    #[test]
    fn can_initialize_correctly(){
        let controller = CpuController::new();
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
        let controller = CpuController::new();
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
}