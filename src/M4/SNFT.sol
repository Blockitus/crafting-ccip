// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SNFT is ERC721URIStorage, OwnerIsCreator {
    string constant TOKEN_URI =
        "https://bafybeifpbdynw7cda6bue4d3tzmnpx2i6glvuh6on7rwgtt36dmbwa45mm.ipfs.nftstorage.link/";
    uint256 internal tokenId;

    constructor() ERC721("SoraNFT", "SNFT") {}

    function mint(address to) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, TOKEN_URI);
        unchecked {
            tokenId++;
        }
    }
}