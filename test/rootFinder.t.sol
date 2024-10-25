// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RootFinder.sol";

contract RootFinderTest is Test {
    RootFinder rootFinder;

    // Initialize the RootFinder contract before each test
    function setUp() public {
        rootFinder = new RootFinder();
    }

    // Test findRootNewX to ensure it converges
    function testFindRootNewX() public {
        // Define inputs for findRootNewX
        uint256 reserveY_ = 1000 ether;
        uint256 liquidity = 5000 ether;
        uint256 strike_ = 1500 ether;
        uint256 sigma_ = 8e17; // 80% volatility
        uint256 tau_ = 365 days; // 1-year duration
        
        bytes memory args = abi.encode(reserveY_, liquidity, strike_, sigma_, tau_);
        
        uint256 initialGuess = 1500 ether;
        uint256 result = rootFinder.findRootNewX(args, initialGuess);

        // Assert result within 1 ether tolerance
        uint256 expectedValue = 1500 ether; // TODO: Replace with actual expected value
        assertApproxEqAbs(result, expectedValue, 1 ether, "Root did not converge to expected value within tolerance");
    }

    // Test computeTfDReserveX to ensure accuracy of f'(L)
    function testComputeTfDReserveX() public {
        // Define inputs for derivative computation
        uint256 reserveY_ = 1000 ether;
        uint256 liquidity = 5000 ether;
        uint256 strike_ = 1500 ether;
        uint256 sigma_ = 1e18; // 100% volatility
        uint256 tau_ = 365 days; // 1-year duration

        bytes memory args = abi.encode(reserveY_, liquidity, strike_, sigma_, tau_);
        uint256 rX = 1200 ether;

        int256 derivative = rootFinder.computeTfDReserveX(args, rX);
        int256 expectedDerivative = -1e18; // TODO: Replace with actual expected derivative

        assertApproxEqAbs(derivative, expectedDerivative, 1e16, "Computed derivative does not match expected value within tolerance");
    }

    // Test findX function to ensure it returns the expected value for given inputs
    function testFindX() public {
        // Test data for findX
        uint256 reserveY_ = 10 ether;
        uint256 liquidity = 500 ether;
        uint256 strike_ = 1500 ether;
        uint256 sigma_ = 1e18; // 100% volatility
        uint256 tau_ = 365 days; // 1-year duration

        bytes memory data = abi.encode(reserveY_, liquidity, strike_, sigma_, tau_);
        uint256 x = 1200 ether;

        int256 result = rootFinder.findX(data, x);

        int256 expectedValue = 0; // TODO: Replace with actual expected outcome
        assertApproxEqAbs(result, expectedValue, 1e16, "findX returned unexpected value");
    }

    // Test computeTradingFunction with known parameters to verify correct calculation
    function testComputeTradingFunction() public {
        uint256 reserveX_ = 200 ether;
        uint256 reserveY_ = 10 ether;
        uint256 liquidity = 10000 ether;
        uint256 strike_ = 1500 ether;
        uint256 sigma_ = 8e17; // 80% volatility
        uint256 tau_ = 365 days; // 1-year duration

        int256 result = rootFinder.computeTradingFunction(reserveX_, reserveY_, liquidity, strike_, sigma_, tau_);

        int256 expectedValue = 1000; // TODO: Replace with actual expected result
        assertApproxEqAbs(result, expectedValue, 1e16, "computeTradingFunction result does not match expected value");
    }

    // Test computeSigmaSqrtTau to ensure correct calculation of sigma * sqrt(tau)
    function testComputeSigmaSqrtTau() public {
        uint256 sigma_ = 8e17; // 80% volatility
        uint256 tau_ = 365 days; // 1-year duration

        uint256 result = rootFinder.computeSigmaSqrtTau(sigma_, tau_);

        uint256 expectedValue = 1157e14; // TODO: Replace with actual expected sigma * sqrt(tau) result
        assertApproxEqAbs(result, expectedValue, 1e16, "computeSigmaSqrtTau result does not match expected value");
    }
    
    // Test toInt function for correct uint256 to int256 conversion and overflow handling
    function testToInt() public {
        uint256 largeNumber = type(uint256).max;

        // Expect revert for input larger than max int256
        vm.expectRevert(bytes("ToIntOverflow"));
        rootFinder.toInt(largeNumber);
        
        uint256 validNumber = uint256(type(int256).max);
        int256 result = rootFinder.toInt(validNumber);
        
        assertEq(result, int256(validNumber), "toInt did not convert uint256 to int256 correctly");
    }

    // Test abs function to ensure correct absolute value calculation for positive and negative inputs
    function testAbs() public {
        int256 positiveValue = 1e18;
        int256 negativeValue = -1e18;

        assertEq(rootFinder.abs(positiveValue), 1e18, "abs failed to return correct value for positive input");
        assertEq(rootFinder.abs(negativeValue), 1e18, "abs failed to return correct value for negative input");
    }
}
