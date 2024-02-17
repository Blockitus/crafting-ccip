// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {LinkTokenInterface} from "../LinkTokenInterface.sol";

contract CCIPSender_Unsafe {
    address router;
    address link;

    constructor(address _router, address _link) {
        router = _router;
        link = _link;
        //b-practice, it is a bad-prectice approve a contract to manage all funds of another one
        LinkTokenInterface(link).approve(router, type(uint256).max);
    }

    function send(
        address receiver,
        string memory someText,
        uint64 destinationChainSelector
    ) external {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(someText),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: link
        });

        IRouterClient(router).ccipSend(destinationChainSelector, message);
    }
}
