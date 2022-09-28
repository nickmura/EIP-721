// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IERC721.sol";
import "./IERC165.sol";
import "./IERC721TokenReciever.sol";

abstract contract ERC721 is IERC721, IERC165, ERC721TokenReceiver {

    mapping(address => uint256) private balances;
    mapping(uint256 => address) private _owners; // owner of a tokenId
    mapping(uint256 => address) public _getApproved;
    mapping(address => mapping (address => bool)) public approvalOfOperator;

    /// balanceOf returns the amount of NFTs a user has minted/owns. Is deducted or added when a user transfers or mints.
    function balanceOf(address _owner) external override view returns (uint256) {
        require(_owner != address(0), "Zero addresses are invalid.");
        return balances[_owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        // owner of tokenId == _owners[tokenId]
        require(_owners[tokenId] != address(0), "Zero addresses are invalid"); // if owner of tokenId is invalid, bad
        return _owners[tokenId];
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external payable {
        require(to != address(0), "Recipient address is invalid");
        transferFrom(from, to, tokenId);
        emit Transfer(from, to, tokenId);

    }
    function transferFrom(address from, address to, uint256 tokenId) public payable {
        require(_owners[tokenId] == msg.sender, "msg.sender is not operator/owner/approved for tokenId");
        require(_owners[tokenId] == from, "Sender does not own such tokenId");
        balances[from] -= 1;

        if (to != address(0)) {
            balances[to] += 1;
        }
        emit Transfer(from, to, tokenId);
    }


    function approve(address _approved, uint256 tokenId) public payable {
        require(_owners[tokenId] == msg.sender, "Caller is not owner of tokenId");
        _getApproved[tokenId] == _approved;
        emit Approval(msg.sender, _approved, tokenId);
    }


    function setApprovalForAll(address _operator, bool _approved) external {
        if (_approved) {
            approvalOfOperator[msg.sender][_operator] = _approved;
        } if (!_approved) {
            approvalOfOperator[msg.sender][_operator] = _approved;
        }
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }


    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        bool _approved;
        if (approvalOfOperator[_owner][_operator] == true) {
            _approved = true;
        }
        if (approvalOfOperator[_owner][_operator] == false) {
            _approved = false;
        }
        return _approved;
    }

}