const { ethers } = require('ethers');


const errorSignatures = 
[
"InsufficientBalance(uint256,uint256)",
"NothingToWithdraw()",
"InvalidReceiverAddress()",
"SenderNotWhitelisted()",
"SenderAlreadyListed()",
"DestinationChainNotWhitelisted(uint64)",
"DestinationChainAlreadyWhiteListed(uint64)",
"InsufficientFeeTokenAmount()"];

const errorIdentifiers = [];
for (let i = 0; i < errorSignatures.length; i++) {
    errorIdentifiers[i] = ethers.utils.id(errorSignatures[i]).slice(0, 10);
}

console.log(errorIdentifiers);