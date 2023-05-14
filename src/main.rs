use clap::Parser;
use colored::*;
#[derive(Parser, Default, Debug)]
#[command(name = "ALVR-Distrobox")]
#[command(author = "PLYSHKA <leruop@gmail.com>")]
#[command(version = "0.0.1")]
#[command(about = "ALVR Distrobox installator and starter", long_about = None)]
struct Arguments {
    #[arg(long, action)]
    setup_phase_2: bool,
    #[arg(long, action)]
    setup_phase_3: bool,
    #[arg(long, action)]
    setup_phase_4: bool,
    #[arg(long)]
    container_name: String,
    #[arg(long)]
    prefix_path: String,
}

fn main() {
    let args: Arguments = Arguments::parse();
    println!("{:?}", args);
    if args.prefix_path.contains(" ") {
        println!("{}",
            "File path to container can't contains spaces as SteamVR will fail to launch if path to it contains spaces."
                .red());
        println!(
            "{}",
            "Please clone or unpack repository into another directory that doesn't contain spaces."
                .red()
        );
        std::process::exit(1)
    }
}
