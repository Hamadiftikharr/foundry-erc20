# Foundry-ERC20-F24

This project implements an ERC-20 token using OpenZeppelin contracts and provides additional features for deployment and testing.

## Overview

The project contains the following key components:

### 1. **OurToken.sol**
- This is the main ERC-20 token contract.
- Inherits the standard ERC-20 implementation from [OpenZeppelin](https://openzeppelin.com/contracts/).
- Implements all core functionalities of an ERC-20 token.

### 2. **ManualToken.sol**
- A custom ERC-20 token implementation created manually for learning and experimentation purposes.
- Provides a basic understanding of how ERC-20 tokens work without relying on libraries.

### 3. **Tests**
- Comprehensive tests for the token contracts are included to ensure their correctness and security.
- Uses [Foundry](https://getfoundry.sh/) for testing.
- Covers standard ERC-20 functionalities like `transfer`, `approve`, and `transferFrom`.

### 4. **Deployment Script**
- Includes a script to deploy the token contracts on the blockchain.
- Script is flexible and supports deployment on test networks like Sepolia or local networks like Anvil.

## How to Use

### Install Dependencies
Make sure you have Foundry installed. If not, install it by following the instructions [here](https://book.getfoundry.sh/getting-started/installation.html).

### Clone the Repository
```bash
git clone https://github.com/Hamadiftikharr/foundry-erc20.git
cd foundry-erc20

Run Tests
To ensure everything is working as expected:

bash
forge test
Deploy the Contract
To deploy the OurToken contract:

bash
forge script script/DeployOurToken.s.sol:DeployOurToken --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
Key Features
Reusable: Uses OpenZeppelin's highly tested and secure libraries for token implementation.
Custom Implementation: ManualToken provides insight into the inner workings of ERC-20 contracts.
Complete Setup: Includes tests and deployment scripts for a full development workflow.
