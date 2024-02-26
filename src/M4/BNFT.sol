// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BNFT is ERC721, OwnerIsCreator {

    string constant baseUri =
        "https://bafybeidvjmeh6pdhon5cytxxfkrvcuzqu7pauewu73u5uqpsp5ry2zt5b4.ipfs.nftstorage.link/";
    uint256 internal tokenId;

    constructor() ERC721("BlockitusNFT", "BNFT") {}

    function _baseURI() internal pure override returns (string memory) {
        return baseUri;
    }

    function mint(address to) public onlyOwner {
       unchecked {
            tokenId++;
        }
        _safeMint(to, tokenId);
        
    }
}