// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Nexus-Swap-AMM
// Built from scratch

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SimpleDEX {
    // 1. Define the token interfaces
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // 2. Define the reserves
    uint256 public reserve0;
    uint256 public reserve1;

    // 3. Define the LP Token total supply
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }
}
