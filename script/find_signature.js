const { ethers } = require('ethers');

const tagError = "0x07da6ee6"
const errorSignature = "InsufficientFeeTokenAmount()";
const errorIdentifier = ethers.utils.id(errorSignature).slice(0,  10);

console.log(errorIdentifier===tagError);