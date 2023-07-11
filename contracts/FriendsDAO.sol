//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import "./Friends.sol";

contract FriendsDAO {
    //** Initiate the friends contract */
    Friends public friendsContract;

    //** Struct contains the parameters that the proposal requires */

    struct Proposal {
        uint256 _tokenId;
        address proposer;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        mapping(address => bool) voted;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    
    uint256 public votingTime = 3 days;

    constructor(address _friendsContractAddress) {
        friendsContract = Friends(_friendsContractAddress);
    }
    modifier canVote() {
        require(friendsContract.balanceOf(msg.sender) == 1, "Not a DAO Member");
        _;
    }

    function createProposal(string calldata _description) external canVote {
        require(bytes(_description).length > 0, "Description cannot be empty");

        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal._tokenId = proposalCount;
        newProposal.proposer = msg.sender;
        newProposal.description = _description;
        newProposal.startTime = block.timestamp;
        newProposal.endTime = block.timestamp + votingTime;
    }

    function vote(uint256 _proposalId, bool _supportsProposal) external canVote {
        require(_proposalId <= proposalCount, "invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "executed proposal");
        require(!proposal.voted[msg.sender], "Member already voted");

        if(_supportsProposal) {
            proposal.forVotes++;
        } else {
            proposal.againstVotes++;
        }
        proposal.voted[msg.sender] = true;
    }
    function executeProposal(uint256 _proposalId) external {
        require(_proposalId<= proposalCount, "invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "executed proposal");
        require(block.timestamp >= proposal.endTime, "Voting period ongoing");

        if(proposal.forVotes > proposal.againstVotes) {
            proposal.executed = true;
        } else if (proposal.forVotes == proposal.againstVotes) {
            proposal.endTime += votingTime;
        }
    }

}