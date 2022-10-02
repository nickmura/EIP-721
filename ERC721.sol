// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IERC721.sol";
import "./IERC165.sol";
import "./IERC721TokenReciever.sol";

contract ERC721 is IERC721, IERC165 {
    // low level call event
    event Response(bool success, bytes data);

    // for onERC721Received() function 
   



    mapping(address => uint256) private balances;
    mapping(uint256 => address) private _owners; // owner of a tokenId
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping (address => bool)) public approvalOfOperator;



    // checks if address is EOA or contract
    function checkAddress(address _addr) internal view returns (bool) {
        uint length;
        assembly {
            length:= extcodesize(_addr)
        }
        return length > 0;
    }

    /// balanceOf returns the amount of NFTs a user has minted/owns. Is deducted or added when a user transfers or mints.
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "Zero address is invalid");
        return balances[_owner];
    }



    function ownerOf(uint256 tokenId) external view returns (address) {
        // owner of tokenId == _owners[tokenId]
        require(_owners[tokenId] != address(0), "Zero addresses are invalid"); // if owner of tokenId is invalid, bad
        return _owners[tokenId];
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable { // safeTransferFrom, no data
        require(to != address(0), "Recipient address is invalid");
        transferFrom(from, to, tokenId);
        emit Transfer(from, to, tokenId);
        if (checkAddress(to) == true) {
            (bool success, bytes memory _data) = to.call(
                abi.encodeWithSignature("onERC721Recieved(address, address, uint256, bytes)", msg.sender, from, tokenId, '0x')
            );
            require(success);
            emit Response(success, _data);

        }
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external payable { // safeTransferFrom, with data
        require(to != address(0), "Recipient address is invalid");
        transferFrom(from, to, tokenId);
        emit Transfer(from, to, tokenId);
        if (checkAddress(to) == true) {
            (bool success, bytes memory _data) = to.call(
                abi.encodeWithSignature("onERC721Recieved(address, address, uint256, bytes)", msg.sender, from, tokenId, data)
            );
            require(success);
            emit Response(success, _data);
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable {
        require(_owners[tokenId] == msg.sender || approvalOfOperator[from][msg.sender] == true || getApproved[tokenId] == msg.sender, "msg.sender is not operator/owner/approved for tokenId");
        require(_owners[tokenId] == from, "Sender does not own such tokenId");

        unchecked {
            balances[from] -= 1;
            balances[to] += 1;
        }


        _owners[tokenId] = to; // transfers ownership
        
        emit Transfer(from, to, tokenId);
    }


    function approve(address _approved, uint256 tokenId) public payable {
        require(_owners[tokenId] == msg.sender, "Caller is not owner of tokenId");
        getApproved[tokenId] == _approved;
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
        return approvalOfOperator[_owner][_operator];
    }


    function _safeMint(address to, uint256 tokenId) internal virtual { //_safeMint with no data parameter.
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data ) internal virtual {
        _mint(to, tokenId);
        if (checkAddress(to)) { // calls onERC721Recieved
            (bool success, bytes memory _data) = to.call(
                abi.encodeWithSignature("onERC721Recieved(address, address, uint256, bytes)", address(0), to, tokenId, data)
            );
            require(success);
            emit Response(success, _data);
        }
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "Minting to a zero address is invalid");
        require(!_exists(tokenId), "Token is already minted");
        unchecked {
            balances[to] += 1;
        }
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        
    }


    /**function isTokenMinted(address to, uint256 tokenId) internal {
        require(_tokenowner[tokenId] == address(0));
    }**/

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }


    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return interfaceID == 0x01ffc9a7 || interfaceID == 0x80ac58cd || interfaceID == 0x150b7a02;
    }
}

