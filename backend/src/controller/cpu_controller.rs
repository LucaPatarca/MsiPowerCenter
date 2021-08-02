#[cfg(debug_assertions)]
const CPUFREQ_PATH: &'static str                   = "/home/luca/MsiPowerCenter/mockFiles/cpufreq/";
#[cfg(debug_assertions)]
const PSTATE_PATH: &'static str                    = "/sys/devices/system/cpu/intel_pstate/";
#[cfg(not(debug_assertions))]
const PSTATE_PATH: &'static str                    = "/home/luca/MsiPowerCenter/mockFiles/intel_pstate/";
#[cfg(not(debug_assertions))]
const CPUFREQ_PATH: &'static str                   = "/sys/devices/system/cpu/";
const PSTATE_MAX_PERF: &'static str                = "/max_perf_pct";
const PSTATE_MIN_PERF: &'static str                = "/min_perf_pct";
const PSTATE_NO_TURBO: &'static str                = "/no_turbo";

const SCALING_MAX_FREQ: &'static str               = "/cpufreq/scaling_max_freq";
const SCALING_MIN_FREQ: &'static str               = "/cpufreq/scaling_min_freq";
const SCALING_GOVERNOR: &'static str               = "/cpufreq/scaling_governor";
const CPUINFO_MAX_FREQ: &'static str               = "/cpufreq/cpuinfo_max_freq";
const CPUINFO_MIN_FREQ: &'static str               = "/cpufreq/cpuinfo_min_freq";
const SCALING_AVAILABLE_GOVERNORS: &'static str    = "/cpufreq/scaling_available_governors";
const ENERGY_PREF: &'static str                    = "/cpufreq/energy_performance_preference";
const ENERGY_AVAILABLE_PREFS: &'static str         = "/cpufreq/energy_performance_available_preferences";

pub struct CpuController {
    cpu_count: i32,
    
}