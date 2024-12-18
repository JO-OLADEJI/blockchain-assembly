## Encode Advanced Solidity Bootcamp Q4 2024 - Final Project

This project features a simple vault contract that has been written in Solidity, Yul - an intermediate level language, and Huff - a low level evm language. The goal is to show proficiency in the understanding of how the ethereum virtual machine works under the hood using opcodes operations on the stack and memory (calldata inclusive).

To run the project:
```shell
git clone https://github.com/JO-OLADEJI/blockchain-assembly.git

# compile
forge build

# run tests
forge test --evm-version shanghai

# deploy contract(s)
forge script script/deploy.sol:DeployScript <target-language> --sig "run(string)" -vvv

# <target-language> can either be `huff`, `yul` or `solidity`
# `huff` has a bug when broadcasting transactions. I'm working on making a PR to the foundry-huff repo.
```
