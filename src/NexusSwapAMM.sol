// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract NexusSwapAMM {
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event AddLiquidity(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 shares
    );
    event RemoveLiquidity(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 shares
    );
    event Swap(
        address indexed user,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOut
    );

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL HELPERS
    //////////////////////////////////////////////////////////////*/
    function _sqrt(uint256 y) internal pure returns (uint256 z) {
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

    function _update(uint256 _reserveA, uint256 _reserveB) private {
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    /*//////////////////////////////////////////////////////////////
                            CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function addLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external returns (uint256 shares) {
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        if (totalSupply == 0) {
            shares = _sqrt(amountA * amountB);
        } else {
            // Calculate shares based on the limiting token ratio to prevent price manipulation
            uint256 shareA = (amountA * totalSupply) / reserveA;
            uint256 shareB = (amountB * totalSupply) / reserveB;
            shares = shareA < shareB ? shareA : shareB;
        }

        require(shares > 0, "Insufficient liquidity minted");

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        _update(
            tokenA.balanceOf(address(this)),
            tokenB.balanceOf(address(this))
        );
        emit AddLiquidity(msg.sender, amountA, amountB, shares);
    }

    function removeLiquidity(
        uint256 shares
    ) external returns (uint256 amountA, uint256 amountB) {
        require(shares > 0, "Invalid shares");

        amountA = (shares * reserveA) / totalSupply;
        amountB = (shares * reserveB) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        _update(
            tokenA.balanceOf(address(this)),
            tokenB.balanceOf(address(this))
        );
        emit RemoveLiquidity(msg.sender, amountA, amountB, shares);
    }

    function getAmountOut(
        uint256 amountIn,
        bool isTokenA
    ) public view returns (uint256 amountOut) {
        (uint256 reserveIn, uint256 reserveOut) = isTokenA
            ? (reserveA, reserveB)
            : (reserveB, reserveA);

        // Fee calculation: 0.3% (997/1000)
        // Multiply first, divide last to maintain precision
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;

        amountOut = numerator / denominator;
    }

    function swap(
        address tokenIn,
        uint256 amountIn,
        uint256 minAmountOut
    ) external returns (uint256 amountOut) {
        bool isTokenA = tokenIn == address(tokenA);
        require(isTokenA || tokenIn == address(tokenB), "Invalid token");

        amountOut = getAmountOut(amountIn, isTokenA);
        require(amountOut >= minAmountOut, "Slippage too high");

        // Interaction: Pull tokens in
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Interaction: Send tokens out
        IERC20(isTokenA ? address(tokenB) : address(tokenA)).transfer(
            msg.sender,
            amountOut
        );

        // Update Reserves
        _update(
            tokenA.balanceOf(address(this)),
            tokenB.balanceOf(address(this))
        );

        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }
}
