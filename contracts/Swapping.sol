// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// just see if this gives and error while compiling
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract TokenSwap {
    IERC20 public token1;
    address public owner1;
    uint public amount1;
    IERC20 public token2;
    address public owner2;
    uint public amount2; // from the API

    // take the amount of token 2 from the API
    constructor(
        address _token1,
        address _owner1,
        uint _amount1,
        address _token2,
        address _owner2,
        uint _amount2
    ) {
        token1 = IERC20(_token1);
        owner1 = _owner1;
        amount1 = _amount1;
        token2 = IERC20(_token2);
        owner2 = _owner2;
        amount2 = _amount2;
    }

    // function swap() public {
    //     require(msg.sender == owner1 || msg.sender == owner2 , "Not authorized");
    //     // require(msg.sender == owner1 || msg.sender == owner2 , "Not authorized");
    //     require(
    //         token1.allowance(owner1, address(this)) >= amount1,
    //         "Token 1 allowance too low"
    //     );
    //     require(
    //         token2.allowance(owner2, address(this)) >= amount2,  // fetch from he API
    //         "Token 2 allowance too low"
    //     );

    //     _safeTransferFrom(token1, owner1, owner2, amount1);
    //     _safeTransferFrom(token2, owner2, owner1, amount2);
    // }

    function fillQuote(
        // The `fromTokenAddress` field from the API response.
        string fromTokenAddress,
        // The `toTokenAddress` field from the API response.
        string toTokenAddress,
        string protocols ,                                            // who should be mad ethe spender-the protocols?
        // The `amounte` field from the API response.
        string amount
    ) public returns (uint256) {
        require(spender != address(0), "Please provide a valid address");
        // Track our balance of the buyToken to determine how much we've bought.
        uint256 boughtAmount = toTokenAddress.balanceOf(address(this));
        fromTokenAddress.approve(protocols, type(uint128).max);   
               swapCallData =            protocols.part                    // how to set the swp data value
        (bool success, ) = swapTarget.call{value: 0}(swapCallData);            // how to get the swap target 
        emit ZeroXCallSuccess(success, boughtAmount);
        require(success, "SWAP_CALL_FAILED");
        boughtAmount = toTokenAddress.balanceOf(address(this)) - boughtAmount;
        emit buyTokenBought(boughtAmount);
        return boughtAmount;
    }


function swap(
        IERC20[] calldata sellToken,
        IERC20[] calldata buyToken,
        address[] calldata spender,
        address payable[] calldata swapTarget,
        bytes[] calldata swapCallData,
        uint256[] memory amount
    ) 

















    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}
