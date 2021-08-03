use serde::Deserialize;
use serde::Serialize;

#[derive(Serialize,Deserialize)]
pub struct Profile{
    pub name : String,
    pub cpu : CpuConfig,
    pub ec : EcConfig
}

#[derive(Serialize,Deserialize)]
pub struct CpuConfig{
    pub max_freq: i32,
    pub min_freq: i32,
    pub max_perf: i32,
    pub min_perf: i32,
    pub governor: String,
    pub energy_pref: String,
    pub turbo: bool
}

#[derive(Serialize,Deserialize)]
pub struct EcConfig{
    pub name : String,
}