use std::{sync::{Arc, atomic::AtomicBool}, thread, time::Duration};

use communication::CommunicationService;
use hwconfig::ProfileController;
use signal_hook::{consts::{SIGINT, SIGTERM}, iterator::Signals};


mod model;
mod hwconfig;
mod communication;
mod profile;
mod utils;

fn test(com_service: &CommunicationService, profile_controller: &ProfileController) -> Result<(), String>{
    let command = com_service.get_command()?;
    if let Some(to_set) = command.to_set{
        match to_set.category {
            communication::Category::CoolerBoost => {
                if let communication::Value::Bool(value) = to_set.value{
                    profile_controller.set_cooler_boost(value)?;
                } else {
                    return Err("wrong value".to_string());
                }
            },
            communication::Category::ChargingLimit => {
                if let communication::Value::Int(value) = to_set.value{
                    profile_controller.set_charging_limit(value as u8)?;
                } else {
                    return Err("wrong value".to_string());
                }
            },
            communication::Category::Profile => {
                if let communication::Value::String(value) = to_set.value{
                    profile_controller.apply_profile(value.as_str())?;
                } else {
                    return Err("wrong value".to_string());
                }
            },
            communication::Category::AvailableProfiles => {
                return Err("cannot set avaliable profiles".to_string());
            }
        }
    }
    if let Some(to_get) = command.to_get{
        match to_get.category{
            communication::Category::CoolerBoost => {
                let cooler_boost = profile_controller.is_cooler_boost_enabled()?;
                com_service.write_object(cooler_boost)?;
            },
            communication::Category::ChargingLimit => {
                let limit = profile_controller.get_charging_limit()?;
                com_service.write_object(limit)?;
            },
            communication::Category::Profile => {
                let profile = profile_controller.read_profile()?;
                com_service.write_object(profile)?;
            },
            communication::Category::AvailableProfiles => {
                let profiles = profile_controller.get_available_profiles();
                com_service.write_object(profiles)?;
            },
        }
    }
    Ok(())
}

fn main() {
    let com_service = CommunicationService::new();
    let com_service_clone = com_service.clone();
    let com_service_clone2 = com_service.clone();
    let profile_controller = ProfileController::new();
    let exec = Arc::new(AtomicBool::from(true));
    let exec_clone = exec.clone();

    let mut signals = Signals::new(&[SIGINT, SIGTERM]).expect("Error mapping signals");

    thread::spawn(move || {
        let mut second_time = false;
        for _ in signals.forever() {
            if second_time{
                std::process::exit(1);
            }else{
                second_time = true;
                exec_clone.store(false, std::sync::atomic::Ordering::Relaxed);
                com_service_clone.send_stop_command().expect("Error writing exit command");
            }
        }
    });

    thread::spawn(move ||{
        let profile_controller_thread = ProfileController::new();
        loop{
            match profile_controller_thread.get_realtime_info() {
                Ok(info) => com_service_clone2.write_realtime_info(info).unwrap_or_else(|e|eprintln!("error: {}",e)),
                Err(e) => eprintln!("error: {}",e)
            }
            thread::sleep(Duration::from_secs(1));
        }
    });
    
    while exec.load(std::sync::atomic::Ordering::Relaxed) {
        match test(&com_service, &profile_controller){
            Ok(()) => (),
            Err(error) => {
                eprintln!("{}", error);
                if let Err(e) = com_service.send_error(error){
                    eprintln!("cannot send error: {}", e);
                }
            }
        }
    }

    println!("\nprogram cleanly stopped");
}