use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, msg,
    program_error::ProgramError, pubkey::Pubkey,
};

entrypoint!(process_instruction);

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    match SimpleVaultProgram::parse_instruction(instruction_data)? {
        SimpleVaultProgram::Deposit { amount } => {
            ProgramInstructions::deposit(program_id, accounts, amount)
        }

        SimpleVaultProgram::Withdraw { amount } => {
            ProgramInstructions::withdraw(program_id, accounts, amount)
        }
        SimpleVaultProgram::SyncBalance => ProgramInstructions::sync_balance(program_id, accounts),
    }
}

#[derive(BorshSerialize, BorshDeserialize, Debug)]
enum SimpleVaultProgram {
    Deposit { amount: u64 },
    Withdraw { amount: u64 },
    SyncBalance,
}

impl SimpleVaultProgram {
    pub fn parse_instruction(data: &[u8]) -> Result<Self, ProgramError> {
        let (selector, calldata) = data
            .split_first()
            .ok_or(ProgramError::InvalidInstructionData)?;

        match *selector {
            0 | 1 => {
                let amount = u64::from_le_bytes(
                    calldata
                        .try_into()
                        .map_err(|_| ProgramError::InvalidInstructionData)?,
                );
                if *selector == 0 {
                    Ok(Self::Deposit { amount })
                } else {
                    Ok(Self::Withdraw { amount })
                }
            }
            2 => {
                if calldata.len() > 0 {
                    return Err(ProgramError::InvalidInstructionData);
                }
                Ok(Self::SyncBalance)
            }
            _ => Err(ProgramError::InvalidInstructionData),
        }
    }
}

struct ProgramInstructions {}

impl ProgramInstructions {
    pub fn deposit(_: &Pubkey, _: &[AccountInfo], _: u64) -> ProgramResult {
        msg!("calling deposit function");
        Ok(())
    }

    pub fn withdraw(_: &Pubkey, _: &[AccountInfo], _: u64) -> ProgramResult {
        msg!("calling withdraw function");
        Ok(())
    }

    pub fn sync_balance(_: &Pubkey, _: &[AccountInfo]) -> ProgramResult {
        msg!("calling sync_balance function");
        Ok(())
    }
}
