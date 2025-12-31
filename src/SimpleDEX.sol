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
    // Events
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    // Define the token interfaces
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // Define the reserves
    uint256 public reserve0;
    uint256 public reserve1;

    // Define the LP Token total supply
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _update() private {
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external returns (uint256 liquidity) {
        // 1. Transfer tokens from user to pool
        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);

        // 2. Mint LP tokens
        if (totalSupply == 0) {
            // first liquidity provider
            liquidity = _sqrt(amount0 * amount1);
        } else {
            liquidity = _min((amount0 * totalSupply) / reserve0, (amount1 * totalSupply) / reserve1);
        }

        require(liquidity > 0, "INSUFFICIENT_LIQUIDITY_MINTED");

        // 3. Update LP balances
        balanceOf[msg.sender] += liquidity;
        totalSupply += liquidity;

        // 4. Update reserves
        _update();

        emit Mint(msg.sender, amount0, amount1);
    }

    /*//////////////////////////////////////////////////////////////
                         MATH HELPERS
    //////////////////////////////////////////////////////////////*/
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x < y ? x : y;
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
