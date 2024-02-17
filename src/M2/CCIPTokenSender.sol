// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/interfaces/IERC20.sol";
import {ChainsListerOperator} from "./ChainsListerOperator.sol";

contract CCIPTokenSender is ChainsListerOperator {
    IRouterClient router;
    IERC20 linkToken;

    address public constant NATIVE_TOKEN =
        address(uint160(uint256(keccak256(abi.encodePacked("NATIVE_TOKEN")))));

    error InsufficientBalance(uint256 currentBalance, uint256 calculatedFees);
    error NothingToWithdraw();
    error InvalidReceiverAddress();

    event TokensTransferred(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        address token, // The token address that was transferred.
        uint256 tokenAmount, // The token amount that was transferred.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the message.
    );

    event Withdrawal(
        address indexed beneficiary,
        address indexed token,
        uint256 amount
    );

    constructor(address _router, address _linkToken) {
        router = IRouterClient(_router);
        linkToken = IERC20(_linkToken);
    }

    receive() external payable {}

    function transferTokensPayLinkToken(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount
    )
        external
        onlyOwner
        onlyWhitelistedChain(_destinationChainSelector)
        returns (bytes32 messageId)
    {
        if (_receiver == address(0)) revert InvalidReceiverAddress();
        Client.EVM2AnyMessage memory message = buildCcipMessage(
            _receiver,
            _token,
            _amount,
            address(linkToken)
        );

        uint256 fees = _ccipFeesManagement(_destinationChainSelector, message);

        IERC20(_token).approve(address(router), _amount);

        messageId = router.ccipSend(_destinationChainSelector, message);

        emit TokensTransferred(
            messageId,
            _destinationChainSelector,
            _receiver,
            _token,
            _amount,
            address(linkToken),
            fees
        );
    }

    function withdraw(address _beneficiary) external {
        uint256 amount = address(this).balance;
        if (amount == 0) revert NothingToWithdraw();
        payable(_beneficiary).transfer(amount);
        emit Withdrawal(_beneficiary, NATIVE_TOKEN, amount);
    }

    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));

        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).transfer(_beneficiary, amount);
        emit Withdrawal(_beneficiary, _token, amount);
    }

    function buildCcipMessage(
        address _receiver,
        address _token,
        uint256 _amount,
        address _feeTokenAddress
    ) public pure returns (Client.EVM2AnyMessage memory message) {
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });

        tokenAmounts[0] = tokenAmount;

        message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: "",
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 0})
            ),
            feeToken: _feeTokenAddress
        });
    }

    function _ccipFeesManagement(
        uint64 _destinationChainSelector,
        Client.EVM2AnyMessage memory message
    ) private returns (uint256 fees) {
        fees = router.getFee(_destinationChainSelector, message);
        uint256 currentBalance = linkToken.balanceOf(address(this));
        if (fees > currentBalance)
            revert InsufficientBalance(currentBalance, fees);
        linkToken.approve(address(router), fees);
    }
}
