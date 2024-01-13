// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {VotingSystem} from "../src/VotingSystem.sol";

contract VotingSystemTest is Test {
    VotingSystem public votingSystem;

    function setUp() public {
        votingSystem = new VotingSystem();
    }

    function testRegisterVoter() public {
        address voter = address(this);
        votingSystem.registerVoter();
        (bool isRegistered, , ) = votingSystem.voters(voter);
        assertTrue(isRegistered, "Voter registration failed");
    }

    function testAddCandidate() public {
        address owner = address(this);
        votingSystem.addCandidate("Candidate 1");
        (string memory name, ) = votingSystem.candidates(0);
        assertEq(name, "Candidate 1", "Candidate addition failed");
    }

    function testVote() public {
        address voter = address(this);
        votingSystem.registerVoter();
        votingSystem.addCandidate("Candidate 1");
        votingSystem.vote(0);
        (, bool hasVoted, ) = votingSystem.voters(voter);
        assertTrue(hasVoted, "Vote casting failed");
    }

    function testCloseVoting() public {
        votingSystem.closeVoting();
        assertFalse(votingSystem.isVotingOpen(), "Voting closure failed");
    }

    function testGetResults() public {
        votingSystem.addCandidate("Candidate 1");
        votingSystem.addCandidate("Candidate 2");
        votingSystem.closeVoting();
        VotingSystem.Candidate[] memory results = votingSystem.getResults();
        assertEq(results.length, 2, "Result retrieval failed");
    }

    // this should failed
    function testEdgeCases() public {
        address voter = address(this);
        // Attempt to register already registered voter
        try votingSystem.registerVoter() {
            fail("Expected revert not received");
        } catch Error(string memory reason) {
            assertEq(
                reason,
                "Voter is already registered",
                "Expected revert reason did not match"
            );
        }

        // Attempt to vote without registration
        try votingSystem.vote(0) {
            fail("Expected revert not received");
        } catch Error(string memory reason) {
            assertEq(
                reason,
                "Voter is not registered",
                "Expected revert reason did not match"
            );
        }

        // Attempt to vote twice
        votingSystem.registerVoter();
        votingSystem.vote(0);
        try votingSystem.vote(0) {
            fail("Expected revert not received");
        } catch Error(string memory reason) {
            assertEq(
                reason,
                "Voter has already voted",
                "Expected revert reason did not match"
            );
        }

        // Attempt to vote after voting is closed
        votingSystem.closeVoting();
        try votingSystem.vote(0) {
            fail("Expected revert not received");
        } catch Error(string memory reason) {
            assertEq(
                reason,
                "Voting is not open",
                "Expected revert reason did not match"
            );
        }

        // Attempt to close voting when it is already closed
        try votingSystem.closeVoting() {
            fail("Expected revert not received");
        } catch Error(string memory reason) {
            assertEq(
                reason,
                "Voting is already closed",
                "Expected revert reason did not match"
            );
        }

        // Attempt to retrieve results when voting is still open
        try votingSystem.getResults() {
            fail("Expected revert not received");
        } catch Error(string memory reason) {
            assertEq(
                reason,
                "Voting is still open",
                "Expected revert reason did not match"
            );
        }
    }
}
