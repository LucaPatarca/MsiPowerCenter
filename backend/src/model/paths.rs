use std::{fs::read_dir, path::{Path, PathBuf}};

pub struct Paths{
    pub pstate_max_perf: PathBuf,
    pub pstate_min_perf: PathBuf,
    pub pstate_no_turbo: PathBuf,
    pub cpufreq_base_path: PathBuf,
    pub scaling_max_freq: Vec<PathBuf>,
    pub scaling_min_freq: Vec<PathBuf>,
    pub scaling_cur_freq: Vec<PathBuf>,
    pub scaling_governor: Vec<PathBuf>,
    pub cpuinfo_max_freq: Vec<PathBuf>,
    pub cpuinfo_min_freq: Vec<PathBuf>,
    pub scaling_available_governors: Vec<PathBuf>,
    pub energy_pref: Vec<PathBuf>,
    pub available_energy_prefs: Vec<PathBuf>
}

impl Paths {
    fn new<'r>(cpufreq: &'r str, pstate: &'r str, cpu_count: i32) -> Self{
        let cpufreq_base_path = Path::new(cpufreq).to_path_buf();
        let pstate_base_path = Path::new(pstate).to_path_buf();
        let scaling_max_freq = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"scaling_max_freq")))).collect();
        let scaling_min_freq = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"scaling_min_freq")))).collect();
        let scaling_cur_freq = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"scaling_cur_freq")))).collect();
        let scaling_governor = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"scaling_governor")))).collect();
        let cpuinfo_max_freq = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"cpuinfo_max_freq")))).collect();
        let cpuinfo_min_freq = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"cpuinfo_min_freq")))).collect();
        let scaling_available_governors = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"scaling_available_governors")))).collect();
        let energy_pref = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"energy_performance_preference")))).collect();
        let available_energy_prefs = (0..cpu_count).map(|i|cpufreq_base_path.join(Path::new(&format!("cpu{}/cpufreq/{}",i,"energy_performance_available_preferences")))).collect();
        Self{
            pstate_max_perf: pstate_base_path.join(Path::new("max_perf_pct")),
            pstate_min_perf: pstate_base_path.join(Path::new("min_perf_pct")),
            pstate_no_turbo: pstate_base_path.join(Path::new("no_turbo")),
            cpufreq_base_path,
            scaling_max_freq,
            scaling_min_freq,
            scaling_cur_freq,
            scaling_governor,
            cpuinfo_min_freq,
            cpuinfo_max_freq,
            scaling_available_governors,
            energy_pref,
            available_energy_prefs
        }
    }

    pub fn new_release() -> Self{
        let cpu_count = Self::get_cpu_count("/sys/devices/system/cpu/");
        Paths::new("/sys/devices/system/cpu/", "/sys/devices/system/cpu/intel_pstate/", cpu_count)
    }

    pub fn new_debug() -> Self{
        let cpu_count = Self::get_cpu_count("/home/luca/MsiPowerCenter/mockFiles/cpufreq/");
        Paths::new("/home/luca/MsiPowerCenter/mockFiles/cpufreq/", "/home/luca/MsiPowerCenter/mockFiles/intel_pstate/", cpu_count)
    }

    pub fn new_test() -> Self{
        let cpu_count = Self::get_cpu_count("test_files/mockFiles/cpufreq/");
        Paths::new("test_files/mockFiles/cpufreq/", "test_files/mockFiles/intel_pstate/", cpu_count)
    }

    pub fn new_test_write(num: i32) -> Self{
        let cpu_count = Self::get_cpu_count(format!("test_files/mockFiles_write{}/cpufreq/",num).as_str());
        Paths::new(format!("test_files/mockFiles_write{}/cpufreq/",num).as_str(), format!("test_files/mockFiles_write{}/intel_pstate/",num).as_str(), cpu_count)
    }

    pub fn new_auto() -> Self{
        if cfg!(debug_assertions){
            Self::new_debug()
        }else {
            Self::new_release()
        }
    }

    fn get_cpu_count<'r>(cpufreq_path: &'r str) -> i32{
        let count = read_dir(Path::new(&cpufreq_path)).unwrap().filter(|entry| {
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