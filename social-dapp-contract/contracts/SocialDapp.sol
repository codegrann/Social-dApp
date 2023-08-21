// contracts/SocialDapp.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocialDapp {
    struct Post {
        uint256 id;
        address author;
        string content;
        uint256 likes;
        Comment[] comments;
    }

    struct Comment {
        address author;
        string content;
    }

    uint256 public postCount;
    mapping(uint256 => Post) public posts;

    function createPost(string memory _content) external {
        postCount++;
        posts[postCount] = Post(postCount, msg.sender, _content, 0, new Comment[](0));
    }

    function likePost(uint256 _postId) external {
        posts[_postId].likes++;
    }

    function commentOnPost(uint256 _postId, string memory _comment) external {
        posts[_postId].comments.push(Comment(msg.sender, _comment));
    }
}
