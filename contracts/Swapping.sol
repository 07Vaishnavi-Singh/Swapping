// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

contract AlphaVaultSwap is Ownable {
    // AlphaVault custom events
    event WithdrawTokens(IERC20 buyToken, uint256 boughtAmount_);
    event EtherBalanceChange(uint256 wethBal_);
    event BadRequest(uint256 wethBal_, uint256 reqAmount_);
    event ZeroXCallSuccess(bool status, uint256 initialBuyTokenBalance);
    event buyTokenBought(uint256 buTokenAmount);
    // event feePercentageChange(uint256 feePercentage);
    event maxTransactionsChange(uint256 maxTransactions);

    /**
     * @dev Event to notify if transfer successful or failed
     * after account approval verified
     */
    event TransferSuccessful(
        address indexed from_,
        address indexed to_,
        uint256 amount_
    );

    IWETH public immutable WETH;

    uint256 public maxTransactions;
   

    constructor() {
        WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        maxTransactions = 25;
        // feePercentage = 0;
    }

   
    function depositToken(IERC20 sellToken, uint256 amount) private {
      
        sellToken.transferFrom(msg.sender, address(this), amount);
        emit TransferSuccessful(msg.sender, address(this), amount);
    }

   

    function setMaxTransactionLimit(uint256 num) external onlyOwner {
        maxTransactions = num;
        emit maxTransactionsChange(maxTransactions);
    }

   
    function withdrawETH(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}

    fallback() external payable {}

    function withdrawToken(IERC20 token, uint256 amount) internal {
        token.transfer(msg.sender, amount);
    }

    function setDestination() internal view returns (address) {
        return msg.sender;
    }

    function transferEth(uint256 amount, address msgSender) internal {
        payable(msgSender).transfer(amount);
    }

   
    function fillQuote(
        // The `fromTokenAddress` field from the API response.
        string fromTokenAddress,
        // The `toTokenAddress` field from the API response.
        string toTokenAddress,
        string protocols ,                                            // who should be made the protocols-the protocols?
        // The `amount` field from the API response.
        string amount
    ) public returns (uint256) {
        require(protocols != address(0), "Please provide a valid address");
        // Track our balance of the toTokenAddress to determine how much we've bought.
        uint256 boughtAmount = toTokenAddress.balanceOf(address(this));
        fromTokenAddress.approve(protocols, type(uint128).max);   
        (bool success, ) = swapTarget.call{value: 0}(swapCallData);          // how to call the swap data 
        emit ZeroXCallSuccess(success, boughtAmount);
        require(success, "SWAP_CALL_FAILED");
        boughtAmount = toTokenAddress.balanceOf(address(this)) - boughtAmount;
        emit toTokenAddressBought(boughtAmount);
        return boughtAmount;
    }

    /**
     * @param amount numbers of token to transfer  in unit256
     */
   function multiSwap(
        IERC20[] calldata fromTokenAddress,
        IERC20[] calldata toTokenAddress,
        uint256[] memory amount,
        address[] calldata fromAddress ,
        uint[] memory slippage,                      // handel slippage 
    
    ) external payable {
        require(
            fromTokenAddress.length <= maxTransactions &&
                fromAddress.length == toTokenAddress.length &&
                protocols.length == fromAddress.length &&
            "Please provide valid data"
        );

        uint256 eth_balance;

        if (msg.value > 0) {
            WETH.deposit{value: msg.value}();
            eth_balance = msg.value;
            emit EtherBalanceChange(eth_balance);
        }

        for (uint256 i = 0; i < fromAddress.length; i++) {
            // ETHER & WETH Withdrawl request.
            if (fromAddress[i] == address(0)) {
                if (eth_balance < amount[i]) {
                    emit BadRequest(eth_balance, amount[i]);
                    break;
                }
                if (amount[i] > 0) {
                    eth_balance -= amount[i];
                    WETH.withdraw(amount[i]);
                    transferEth(amount[i], setDestination());
                    emit EtherBalanceChange(eth_balance);
                }
                continue;
            }
            // Condition For using Deposited Ether before using WETH From user balance.
            if (fromTokenAddress[i] == WETH) {
                if (fromTokenAddress[i] == toTokenAddress[i]) {
                    depositToken(fromTokenAddress[i], amount[i]);
                    eth_balance += amount[i];
                    emit EtherBalanceChange(eth_balance);
                    continue;
                }
                eth_balance -= amount[i];
                emit EtherBalanceChange(eth_balance);
            } else {
                depositToken(fromTokenAddress[i], amount[i]);
            }

            // Variable to store amount of tokens purchased.
            uint256 boughtAmount = fillQuote(
                toTokenAddress[i],
                fromTokenAddress[i],
                fromAddress[i],
               amount[i]
            );

            if (toTokenAddress[i] == WETH) {
                eth_balance += boughtAmount;
                emit EtherBalanceChange(eth_balance);
            } else {
                withdrawToken(toTokenAddress[i], boughtAmount);
                emit WithdrawTokens(toTokenAddress[i], boughtAmount);
            }
        }
        if (eth_balance > 0) {
            withdrawToken(WETH, eth_balance);
            emit EtherBalanceChange(0);
        }
    
}
}