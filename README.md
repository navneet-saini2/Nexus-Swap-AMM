# Nexus-Swap-AMM 🚀

A professional-grade **constant-product Automated Market Maker (AMM)** implemented in Solidity.  
This project demonstrates the core mechanics of decentralized exchanges (DEXs) like **Uniswap V2**, focusing on **mathematical precision, gas efficiency, and security**.

---

## 📌 Overview

**NexusSwap** allows users to provide liquidity and swap ERC-20 tokens in a permissionless environment.  
It uses the **Constant Product Formula** to determine prices and maintain pool equilibrium.

### Key Features
- **Liquidity Provision**  
  Users can add/remove liquidity and receive LP shares.

- **Automated Swaps**  
  Built-in pricing engine with a **0.3% trading fee**.

- **Mathematical Safety**  
  Uses the **Babylonian method** for square root calculations and scaled arithmetic to avoid precision loss.

- **Security First**  
  Implements the **Checks-Effects-Interactions (CEI)** pattern to mitigate reentrancy risks.

---

## 📐 The Math Behind the Pool

This AMM follows the invariant:

\[
x \cdot y = k
\]

Where:
- **x** → Reserve of Token A  
- **y** → Reserve of Token B  
- **k** → Constant invariant  

During swaps, reserves update such that `k` remains constant (excluding fees).

---

## 💰 Trading Fees

A **0.3% fee** is charged on every swap.  
Fees are added back into the pool reserves, increasing LP share value over time.

---

## 🛠️ Project Structure

```text
src/
├── NexusSwapAMM.sol   # Core AMM logic (liquidity + swaps)
└── IERC20.sol         # ERC-20 interface
