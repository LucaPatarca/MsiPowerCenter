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
    pub scaling_max_freq: i32,
}

#[derive(Serialize,Deserialize)]
pub struct EcConfig{
    pub name : String,
}