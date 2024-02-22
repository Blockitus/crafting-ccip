// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";


contract SenderListerOperator is OwnerIsCreator {

    mapping(address => bool) senders;

    error SenderNotWhitelisted();
    error SenderAlreadyListed();

    modifier onlyWhitelistedSenders(address _sender) {
        if(!senders[_sender])revert SenderNotWhitelisted();
        _;
    }

    function whitelistSender(address _sender) external onlyOwner {
        if(senders[_sender])revert SenderAlreadyListed();
        senders[_sender] = true;
    }

    function denySender(address _sender) external onlyOwner {
        if(!senders[_sender]) revert SenderNotWhitelisted();
        senders[_sender] = false;
    }

}
