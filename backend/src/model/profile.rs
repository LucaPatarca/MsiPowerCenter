use serde::Deserialize;
use serde::Serialize;

#[derive(Serialize,Deserialize)]
pub struct Profile{
    pub name : String,
    pub cpu : CpuConfig,
    pub ec : EcConfig
}

#[derive(Serialize,Deserialize, Clone)]
pub struct CpuConfig{
    pub max_freq: i32,
    pub min_freq: i32,
    pub max_perf: i32,
    pub min_perf: i32,
    pub governor: String,
    pub energy_pref: String,
    pub turbo: bool
}

#[derive(Serialize,Deserialize, PartialEq, Debug, Clone)]
pub struct EcConfig{
    pub cpu_fan_config : Vec<FanConfig>,
    pub gpu_fan_config : Vec<FanConfig>,
    pub cooler_boost: bool
}

#[derive(Serialize,Deserialize, PartialEq, Debug, Clone)]
pub struct FanConfig{
    pub speed: u8,
    pub temp: u8
}