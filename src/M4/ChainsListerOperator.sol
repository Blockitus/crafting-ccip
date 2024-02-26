// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SenderListerOperator} from "./SenderListerOperator.sol";

contract ChainsListerOperator is SenderListerOperator {
    mapping(uint64 => bool) public whitelistedChains;

    error chainNotWhitelisted(uint64 destinationChainSelector);
    error chainAlreadyWhiteListed(uint64 destinationChainSelector);

    modifier onlyWhitelistedChain(uint64 _destinationChainSelector) {
        if (!whitelistedChains[_destinationChainSelector])
            revert chainNotWhitelisted(_destinationChainSelector);
        _;
    }

    function whitelistChain(
        uint64 _destinationChainSelector
    ) external onlyOwner {
        if (whitelistedChains[_destinationChainSelector])
            revert chainAlreadyWhiteListed(
                _destinationChainSelector
            );
        whitelistedChains[_destinationChainSelector] = true;
    }

    function denylistChain(
        uint64 _destinationChainSelector
    ) external onlyOwner {
        if (!whitelistedChains[_destinationChainSelector])
            revert chainNotWhitelisted(_destinationChainSelector);
        whitelistedChains[_destinationChainSelector] = false;
    }
}
