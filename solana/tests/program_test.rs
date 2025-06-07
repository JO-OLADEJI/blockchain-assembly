use dirs;
use once_cell::sync::Lazy;
use std::{path::PathBuf, str::FromStr};

use solana_client::rpc_client::RpcClient;
use solana_sdk::{
    commitment_config::CommitmentConfig,
    instruction::{AccountMeta, Instruction},
    pubkey::Pubkey,
    signature::{read_keypair_file, Keypair},
    signer::Signer,
    system_program,
    transaction::Transaction,
};

/*
 * This test uses a local rpc node using `solana-test-validator`
 * Test can be run using the following steps
 * - generate shared object (.so) file using `cargo build-sbf`
 * - start client using `solana-test-validator --reset --bpf-program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM target/deploy/solana_simple_vault.so`
 * - run tests using `cargo test -- --nocapture`
 */

static LOCAL_NODE: Lazy<RpcClient> = Lazy::new(|| {
    RpcClient::new_with_commitment("http://localhost:8899", CommitmentConfig::confirmed())
});

static WHITE_HAT: Lazy<Keypair> = Lazy::new(|| {
    read_keypair_file(expand_tilde("~/.config/solana/id.json")).expect("failed to read keypair")
});

static PROGRAM_ID: Lazy<Pubkey> =
    Lazy::new(|| Pubkey::from_str("1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM").unwrap());

#[test]
fn test_deposit() {
    let amount: u64 = 1;
    let calldata: Vec<u8> = {
        let mut x = vec![0];
        x.extend(amount.to_le_bytes());
        x
    };

    let instruction = Instruction::new_with_bytes(
        *PROGRAM_ID,
        &calldata,
        vec![
            AccountMeta::new(WHITE_HAT.pubkey(), true),
            AccountMeta::new_readonly(system_program::id(), false),
        ],
    );

    let tx_hash = LOCAL_NODE
        .send_and_confirm_transaction(&Transaction::new_signed_with_payer(
            &[instruction],
            Some(&WHITE_HAT.pubkey()),
            &[&WHITE_HAT],
            LOCAL_NODE.get_latest_blockhash().unwrap(),
        ))
        .unwrap();
    println!("Deposit tx: {:?}", tx_hash);
}

#[test]
fn test_withdraw() {
    let amount: u64 = 1;
    let calldata: Vec<u8> = {
        let mut x = vec![1];
        x.extend(amount.to_le_bytes());
        x
    };

    let instruction = Instruction::new_with_bytes(
        *PROGRAM_ID,
        &calldata,
        vec![
            AccountMeta::new(WHITE_HAT.pubkey(), true),
            AccountMeta::new_readonly(system_program::id(), false),
        ],
    );

    let tx_hash = LOCAL_NODE
        .send_and_confirm_transaction(&Transaction::new_signed_with_payer(
            &[instruction],
            Some(&WHITE_HAT.pubkey()),
            &[&WHITE_HAT],
            LOCAL_NODE.get_latest_blockhash().unwrap(),
        ))
        .unwrap();
    println!("Withdraw tx: {:?}", tx_hash);
}

#[test]
fn test_sync_balance() {
    let calldata: Vec<u8> = vec![2];

    let instruction = Instruction::new_with_bytes(
        *PROGRAM_ID,
        &calldata,
        vec![
            AccountMeta::new(WHITE_HAT.pubkey(), true),
            AccountMeta::new_readonly(system_program::id(), false),
        ],
    );

    let tx_hash = LOCAL_NODE
        .send_and_confirm_transaction(&Transaction::new_signed_with_payer(
            &[instruction],
            Some(&WHITE_HAT.pubkey()),
            &[&WHITE_HAT],
            LOCAL_NODE.get_latest_blockhash().unwrap(),
        ))
        .unwrap();
    println!("SyncBalance tx: {:?}", tx_hash);
}

fn expand_tilde(path: &str) -> PathBuf {
    if path.starts_with("~/") {
        if let Some(home_dir) = dirs::home_dir() {
            return home_dir.join(&path[2..]);
        }
    }
    PathBuf::from(path)
}
