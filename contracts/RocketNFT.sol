// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract RocketNFT is Ownable {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    string private _name;
    string private _symbol;
    string private _tokenURI;
    uint256 public price;
    uint256 public tokenTracker;
    uint256 public maxSupply;

    mapping(address => mapping(uint256 => uint256)) private _tokenOwnerIndexed;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_, string memory tokenURI_, uint256 price_, uint256 maxSupply_, address initialOwner) Ownable(initialOwner) {
        _name = name_;
        _symbol = symbol_;
        _tokenURI = tokenURI_;
        price = price_;
        maxSupply = maxSupply_;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "RocketNFT: address zero is not a valid owner");
        return _balances[owner];
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        require(owner != address(0), "RocketNFT: address zero is not a valid owner");
        require(index < balanceOf(owner), "RocketNFT: index is over the range");

        return _tokenOwnerIndexed[owner][index];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "RocketNFT: invalid token ID");
        return owner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        _requireMinted(tokenId);
        return _tokenURI;
    }

    function _baseURI() internal pure returns (string memory) {
        return "";
    }

    function mint(uint24 count) external payable {
        require(count > 0, "RocketNFT: ivalid count");
        require(msg.value > count * price, "RocketNFT: insufficient value");
        require(maxSupply >= tokenTracker + count, "RocketNFT: insufficient supply");

        uint256 balanceOwner = balanceOf(msg.sender);
        for (uint256 i = tokenTracker; i < tokenTracker + count; i ++) {
            _mint(msg.sender, i);
            _tokenOwnerIndexed[msg.sender][balanceOwner + i - tokenTracker] = i;
        }
        tokenTracker = tokenTracker + count;

        if (msg.value > count * price) {
            payable(msg.sender).transfer(msg.value - count * price);
        }
    }

    function totalSupply() public view returns (uint256) {
        return tokenTracker;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "RocketNFT: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "RocketNFT: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "RocketNFT: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "RocketNFT: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function withdraw(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        console.log(string(data));
        _transfer(from, to, tokenId);
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        return _owners[tokenId];
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "RocketNFT: mint to the zero address");
        require(!_exists(tokenId), "RocketNFT: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        require(!_exists(tokenId), "RocketNFT: token already minted");

        unchecked {
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        owner = ownerOf(tokenId);

        delete _tokenApprovals[tokenId];

        unchecked {
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "RocketNFT: transfer from incorrect owner");
        require(to != address(0), "RocketNFT: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);
        require(ownerOf(tokenId) == from, "RocketNFT: transfer from incorrect owner");

        delete _tokenApprovals[tokenId];

        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal {
        require(owner != operator, "RocketNFT: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _requireMinted(uint256 tokenId) internal view {
        require(_exists(tokenId), "RocketNFT: invalid token ID");
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal {}

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal {}

    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}