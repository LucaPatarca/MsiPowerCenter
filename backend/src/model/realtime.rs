use serde::Deserialize;
use serde::Serialize;

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct RealTimeECInfo{
    pub cpu_temp: u8,
    pub gpu_temp: u8,
    pub cpu_fan_speed: u8,
    pub gpu_fan_speed: u8,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct RealTimeCPUInfo{
    pub freq: i32,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct RealTimeInfo{
    pub cpu_temp: u8,
    pub gpu_temp: u8,
    pub cpu_fan_speed: u8,
    pub gpu_fan_speed: u8,
    pub freq: i32,
}

impl RealTimeInfo{
    pub fn from_ec_cpu(ec: RealTimeECInfo, cpu: RealTimeCPUInfo) -> Self{
        RealTimeInfo{
            cpu_temp: ec.cpu_temp,
            gpu_temp: ec.gpu_temp,
            cpu_fan_speed: ec.cpu_fan_speed,
            gpu_fan_speed: ec.gpu_fan_speed,
            freq: cpu.freq
        }
    }
}