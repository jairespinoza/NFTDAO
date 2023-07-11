//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Friends is ERC721Enumerable {
    constructor() ERC721("Friends", "FNS"){}
    struct Auction {
        address highestBidder;
        uint256 highesBid;
        uint256 auctionEndTime;
    }
    mapping(address => bool) public hasMinted;
    mapping(address => uint256) public dailyMintCounts;
    mapping(address => Auction) public auctions;
    uint256 public members;

    uint256 public mintingLimit = 1;
    uint256 public coolDownTime = 1 days;

    function mintNFT() public {
        require(dailyMintCounts[msg.sender] < mintingLimit, "User has minted already");
        require(!hasMinted[msg.sender], "User already owns 1 nft");
        require(auctions[msg.sender].auctionEndTime <block.timestamp, "Ongoing auction pending");

        auctions[msg.sender] = Auction(msg.sender, 0, block.timestamp + coolDownTime);

        hasMinted[msg.sender] = true;
        members += 1;
    }
    function placeBid() public payable {
        Auction storage auction = auctions[msg.sender];
        require(auction.auctionEndTime >= block.timestamp, "Auction has ended");
        require(!hasMinted[msg.sender], "User already owns 1 nft");
        require(msg.value > auction.highesBid, "Bid must be higher than highest bid");

        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highesBid);
        }
        auction.highestBidder = msg.sender;
        auction.highesBid = msg.value;
    }
    function claimNFT() public {
        Auction storage auction = auctions[msg.sender];
        require(auction.auctionEndTime< block.timestamp, "Auction ongoing");
        _safeMint(auction.highestBidder, totalSupply()+1);

        dailyMintCounts[auction.highestBidder]++;

        delete auctions[auction.highestBidder];
    }
} 
