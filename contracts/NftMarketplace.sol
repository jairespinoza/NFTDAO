//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import "./Friends.sol";

contract NFTMarketplace{
    Friends public friendsContract;

    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool active;
    }
    mapping (uint256 => Listing) public listings;

    event ListingCreated(uint256 indexed tokenId, address indexed seller, uint256  price);
    event ListingCancelled(uint256 indexed tokenId);
    event NFTSold(uint256 indexed tokenId, address indexed seller, uint256 price);

    constructor(address _FriendsContractAddress) {
        friendsContract = Friends(_FriendsContractAddress);
    }

    function createListing(uint256 _tokenId, uint256 _price) external {
        require(friendsContract.ownerOf(_tokenId) == msg.sender, "User is not owner");
        require(!listings[_tokenId].active, "NFT already listed");

        friendsContract.safeTransferFrom(msg.sender,address(this), _tokenId);

        listings[_tokenId] = Listing(_tokenId, msg.sender, _price, true);

        emit ListingCreated(_tokenId, msg.sender, _price);
    }

    function cancelListing(uint256 _tokenId) external {
        Listing storage listing = listings[_tokenId];
        require(listing.active, "NFT is not listed for sale");
        require(listing.seller == msg.sender, "Not Owner of NFT");

        friendsContract.safeTransferFrom(address(this), msg.sender, _tokenId);

        delete listings[_tokenId];

        emit ListingCancelled(_tokenId);
    }

    function buyNFT(uint256 _tokenId) external payable {
        Listing storage listing = listings[_tokenId];
        require(listing.active, "NFT is not listed for sale");
        require(msg.value == listing.price, "Incorrect amount");
        require(!friendsContract.hasMinted(msg.sender), "You already own an NFT");

        friendsContract.safeTransferFrom(address(this), msg.sender, _tokenId);

        delete listings[_tokenId];

        emit NFTSold(_tokenId, address(this), listing.price);
    }

    function getPrice(uint256 _tokenId) external view returns(uint256) {
        Listing storage listing = listings[_tokenId];
        require(listing.active, "NFT not for sale");

        return listing.price;
    }

    function isListed(uint256 _tokenId) external view returns(bool) {
        Listing storage listing = listings[_tokenId];
        require(listing.active, "NFT not for sale");

        return listing.active;
    }

    

}
