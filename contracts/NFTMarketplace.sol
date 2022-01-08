// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./AcademyToken.sol";
import "./NFTBoredCryptons.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is AccessControl, Pausable, Ownable {
    AcademyToken token;
    NFTBoredCryptons NFTToken;

    uint256 listingsCounter = 0;

    Listing[] listings;

    struct Listing {
        address owner; // owner address
        uint256 id; // nft id
        uint256 price; // ACDM price
        bytes32 status; // trade status (Open, Sold, Cancelled)
    }

    constructor(address _currencyTokenAddress, address _NFTTokenAddress) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        token = AcademyToken(_currencyTokenAddress);
        NFTToken = NFTBoredCryptons(_NFTTokenAddress);
    }

    modifier isAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "You are not an admin"
        );
        _;
    }

    event CreateItem(
        address indexed creator,
        address indexed to,
        uint256 indexed itemID
    );

    event ListingStatusChange(uint256 _listingId, string _status);

    /** @dev Create new NFT item
     * @param _to NFT item recepient
     * @param _tokenURI NFT URI
     *
     * Requirements:
     *
     * - Listing item price should be greater than zero
     */
    function createItem(address _to, string memory _tokenURI)
        external
        onlyOwner
        whenNotPaused
        returns (uint256 _id)
    {
        _id = NFTToken.safeMint(_to, _tokenURI);

        emit CreateItem(msg.sender, _to, _id);
    }

    /** @dev List NFT on marketplace
     * @param _id NFT id
     * @param _price NFT price for trade
     *
     * Requirements:
     *
     * - Listing item price should be greater than zero
     */
    function listItem(uint256 _id, uint256 _price) external whenNotPaused {
        require(
            _price > 0,
            "NFT Marketplace: Listing item price should be greater than zero"
        );

        NFTToken.safeTransferFrom(msg.sender, address(this), _id);

        listings.push(
            Listing({owner: msg.sender, id: _id, price: _price, status: "Open"})
        );

        emit ListingStatusChange(listingsCounter, "Open");

        listingsCounter++;
    }

    /** @dev Buy listed NFT
     * @param _listingId listing id
     *
     * Requirements:
     *
     * - Listing status should be "Open"
     */
    function buyItem(uint256 _listingId) external whenNotPaused {
        Listing memory listing = listings[_listingId];

        require(listing.status == "Open", "Listing is not Open.");

        token.transferFrom(msg.sender, listing.owner, listing.price);
        NFTToken.safeTransferFrom(address(this), msg.sender, listing.id);

        listing.status = "Sold";

        emit ListingStatusChange(_listingId, "Sold");
    }

    /** @dev Cancel listed NFT
     * @param _listingId listing id
     *
     * Requirements:
     *
     * - Only listing owner can cancel listing
     * - Listing status should be "Open"
     */
    function cancel(uint256 _listingId) external whenNotPaused {
        Listing memory listing = listings[_listingId];

        require(
            msg.sender == listing.owner,
            "NFT Marketplace: Only listing owner can cancel listing"
        );
        require(listing.status == "Open", "Listing is not Open");

        NFTToken.safeTransferFrom(address(this), listing.owner, listing.id);
        listings[_listingId].status = "Cancelled";

        emit ListingStatusChange(_listingId, "Cancelled");
    }

    /**
     * @dev Triggers stopped state
     *
     * Requirements:
     *
     * - The contract must not be paused
     */
    function pause() external isAdmin {
        _pause();
    }

    /**
     * @dev Returns to normal state
     *
     * Requirements:
     *
     * - The contract must be paused
     */
    function unpause() external isAdmin {
        _unpause();
    }
}
