use ini::Ini;
use serde::Deserialize;
use serde::Serialize;

#[derive(Serialize,Deserialize, Clone)]
pub struct Profile{
    pub name : String,
    pub cpu : CpuConfig,
    pub ec : EcConfig
}

impl Profile{
    pub fn from_ini(ini: &Ini) -> Result<Self, String>{
        let cpu = CpuConfig::from_ini(ini)?;
        let ec = EcConfig::from_ini(ini)?;
        if let Some(name) = ini.get_from(Some("General"), "Name"){
            Ok(Self{cpu,ec,name: String::from(name)})
        } else {
            Err(String::from("No name"))
        }
    }
}

#[derive(Serialize,Deserialize, Clone, PartialEq)]
pub struct CpuConfig{
    pub max_freq: i32,
    pub min_freq: i32,
    pub max_perf: i32,
    pub min_perf: i32,
    pub governor: String,
    pub energy_pref: String,
    pub turbo: bool
}

impl CpuConfig{
    pub fn from_ini(ini: &Ini) -> Result<Self, String>{
        Ok(Self{
            max_freq: get_int(ini, "Power", "CpuMaxFreq")?,
            min_freq: get_int(ini, "Power", "CpuMinFreq")?,
            max_perf: get_int(ini, "Power", "CpuMaxPerf")?,
            min_perf: get_int(ini, "Power", "CpuMinPerf")?,
            governor: get_string(ini, "Power", "CpuScalingGovernor")?,
            energy_pref: get_string(ini, "Power", "CpuEnergyPreference")?,
            turbo: get_bool(ini, "Power", "CpuTurboEnabled")?,
        })
    }
}

#[derive(Serialize,Deserialize, PartialEq, Debug, Clone)]
pub struct EcConfig{
    pub cpu_fan_config : Vec<FanConfig>,
    pub gpu_fan_config : Vec<FanConfig>,
    pub cooler_boost: bool
}

impl EcConfig{
    pub fn from_ini(ini: &Ini) -> Result<Self, String>{
        let cpu_temps = get_int_list(ini, "Temperature", "CpuTemps")?;
        let gpu_temps = get_int_list(ini, "Temperature", "GpuTemps")?;
        let cpu_fans = get_int_list(ini, "Fan", "CpuFanSpeeds")?;
        let gpu_fans = get_int_list(ini, "Fan", "GpuFanSpeeds")?;
        let mut cpu_fan_config = Vec::new();
        let mut gpu_fan_config = Vec::new();
        for i in 0..7{
            cpu_fan_config.push(FanConfig{temp: cpu_temps[i] as u8, speed:cpu_fans[i] as u8});
            gpu_fan_config.push(FanConfig{temp: gpu_temps[i] as u8, speed:gpu_fans[i] as u8});
        }
        Ok(Self{
            cpu_fan_config,
            gpu_fan_config,
            cooler_boost: get_bool(ini, "Fan", "CoolerBoost")?
        })
    }
}

#[derive(Serialize,Deserialize, PartialEq, Debug, Clone)]
pub struct FanConfig{
    pub speed: u8,
    pub temp: u8
}

fn get_string(ini: &Ini, sec: &'static str, key: &'static str) -> Result<String, String>{
    let str = ini.get_from(Some(sec), key).ok_or(format!("{} not found", key))?;
    Ok(String::from(str))
}

fn get_int(ini: &Ini, sec: &'static str, key: &'static str) -> Result<i32, String>{
    get_string(ini,sec,key)?.parse().map_err(|e|format!("parse error: {}", e))
}

fn get_bool(ini: &Ini, sec: &'static str, key: &'static str) -> Result<bool, String>{
    get_string(ini, sec, key)?.parse().map_err(|e|format!("parse error: {}", e))
}

fn get_int_list(ini: &Ini, sec: &'static str, key: &'static str) -> Result<Vec<i32>, String>{
    get_string(ini,sec,key)?.split(";").map(|e|String::from(e).parse().map_err(|e|format!("parsee error: {}",e))).collect()
}

//TODO test