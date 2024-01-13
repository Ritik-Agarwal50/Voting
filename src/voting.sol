// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    address public owner;
    bool public votingOpen;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    event VoterRegistered(address indexed voter);
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoteCasted(address indexed voter, uint256 indexed candidateId);
    event VotingClosed();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "Voter is not registered");
        _;
    }

    modifier onlyOnce() {
        require(!voters[msg.sender].hasVoted, "Voter has already voted");
        _;
    }

    modifier onlyDuringVoting() {
        require(votingOpen, "Voting is not open");
        _;
    }

    constructor() {
        owner = msg.sender;
        votingOpen = true;
    }

    function registerVoter() external {
        require(
            !voters[msg.sender].isRegistered,
            "Voter is already registered"
        );
        voters[msg.sender].isRegistered = true;
        emit VoterRegistered(msg.sender);
    }

    function addCandidate(string memory _name) external onlyOwner {
        uint256 candidateId = candidates.length;
        candidates.push(Candidate(_name, 0));
        emit CandidateAdded(candidateId, _name);
    }

    function vote(
        uint256 _candidateId
    ) external onlyRegisteredVoter onlyOnce onlyDuringVoting {
        require(_candidateId < candidates.length, "Invalid candidate ID");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
        emit VoteCasted(msg.sender, _candidateId);
    }

    function closeVoting() external onlyOwner {
        require(votingOpen, "Voting is already closed");
        votingOpen = false;
        emit VotingClosed();
    }

    function getResults() external view returns (Candidate[] memory) {
        require(!votingOpen, "Voting is still open");
        return candidates;
    }
}
