// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import { Gaussian } from "lib/solstat/src/Gaussian.sol";
import { FixedPointMathLib } from "lib/solmate/src/utils/FixedPointMathLib.sol";
import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";

using FixedPointMathLib for uint256;
using FixedPointMathLib for int256;

/// @title RootFinder
/// @notice A contract for finding roots using numerical methods
/// @dev Uses Newton's method for root finding
contract RootFinder {
    uint256 private constant MAX_ITERATIONS = 20;
    uint256 private constant TOLERANCE = 10;

    /// @notice Finds the root of a function using Newton's method
    /// @param args Encoded arguments for the function
    /// @param initialGuess Initial guess for the root
    /// @return reserveX_ The found root
    function findRootNewX(bytes memory args, uint256 initialGuess) public pure returns (uint256 reserveX_) {
        reserveX_ = initialGuess;
        int256 reserveX_next;

        for (uint256 i = 0; i < MAX_ITERATIONS; i++) {
            int256 dfx = computeTfDReserveX(args, reserveX_);
            int256 fx = findX(args, reserveX_);

            if (dfx == 0) {
                // Handle division by zero
                break;
            }

            reserveX_next = int256(reserveX_) - fx * 1e18 / dfx;

            if (abs(int256(reserveX_) - reserveX_next) <= int256(TOLERANCE) || abs(fx) <= int256(TOLERANCE)) {
                reserveX_ = uint256(reserveX_next);
                break;
            }

            reserveX_ = uint256(reserveX_next);
        }
    }

    /// @notice Computes the derivative of the trading function with respect to reserveX
    /// @param args Encoded arguments for the function
    /// @param rX Current value of reserveX
    /// @return The computed derivative
    function computeTfDReserveX(bytes memory args, uint256 rX) internal pure returns (int256) {
        (, uint256 L,,,) = abi.decode(args, (uint256, uint256, uint256, uint256, uint256));
        int256 a = Gaussian.ppf(toInt(rX * 1e18 / L));
        int256 pdf_a = Gaussian.pdf(a);
        return 1e36 / (int256(L) * pdf_a / 1e18);
    }

    /// @notice Finds the value of X in the trading function
    /// @param data Encoded arguments for the function
    /// @param x Current value of X
    /// @return The computed value of the trading function
    function findX(bytes memory data, uint256 x) internal pure returns (int256) {
        (uint256 reserveY_, uint256 liquidity, uint256 strike_, uint256 sigma_, uint256 tau_) =
            abi.decode(data, (uint256, uint256, uint256, uint256, uint256));

        return computeTradingFunction(x, reserveY_, liquidity, strike_, sigma_, tau_);
    }

    /// @notice Computes the trading function
    /// @param reserveX_ Reserve X
    /// @param reserveY_ Reserve Y
    /// @param liquidity Liquidity
    /// @param strike_ Strike price
    /// @param sigma_ Volatility
    /// @param tau_ Time to expiration
    /// @return The computed value of the trading function
    function computeTradingFunction(
        uint256 reserveX_,
        uint256 reserveY_,
        uint256 liquidity,
        uint256 strike_,
        uint256 sigma_,
        uint256 tau_
    ) internal pure returns (int256) {
        uint256 a_i = reserveX_ * 1e18 / liquidity;
        uint256 b_i = reserveY_ * 1e36 / (strike_ * liquidity);

        int256 a = Gaussian.ppf(toInt(a_i));
        int256 b = Gaussian.ppf(toInt(b_i));
        int256 c = tau_ != 0 ? toInt(computeSigmaSqrtTau(sigma_, tau_)) : int256(0);
        return a + b + c;
    }

    /// @notice Computes sigma * sqrt(tau)
    /// @param sigma_ Volatility
    /// @param tau_ Time to expiration
    /// @return The computed value of sigma * sqrt(tau)
    function computeSigmaSqrtTau(uint256 sigma_, uint256 tau_) internal pure returns (uint256) {
        uint256 sqrtTau = FixedPointMathLib.sqrt(tau_) * 1e9;
        return sigma_.mulWadUp(sqrtTau);
    }

    /// @notice Converts a uint256 to an int256
    /// @param x The uint256 value to convert
    /// @return The converted int256 value
    function toInt(uint256 x) internal pure returns (int256) {
        require(x <= uint256(type(int256).max), "ToIntOverflow");
        return int256(x);
    }

    /// @notice Computes the absolute value of an int256
    /// @param x The int256 value
    /// @return The absolute value of x
    function abs(int256 x) internal pure returns (int256) {
        return x < 0 ? -x : x;
    }
}
