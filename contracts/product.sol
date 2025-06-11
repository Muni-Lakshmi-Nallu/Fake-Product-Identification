// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract Product {

    // State variables for tracking sellers and products
    uint256 public sellerCount;
    uint256 public productCount;

    // Seller structure to hold seller details
    struct Seller {
        uint256 sellerId;
        bytes32 sellerName;
        bytes32 sellerBrand;
        bytes32 sellerCode;
        uint256 sellerNum;
        bytes32 sellerManager;
        bytes32 sellerAddress;
    }

    // Product structure to hold product details
    struct ProductItem {
        uint256 productId;
        bytes32 productSN;
        bytes32 productName;
        bytes32 productBrand;
        uint256 productPrice;
        bytes32 productStatus;
    }

    // Mappings to store seller and product data
    mapping(uint256 => Seller) public sellers;
    mapping(uint256 => ProductItem) public productItems;
    mapping(bytes32 => uint256) public productMap; // Maps product serial number to product ID
    mapping(bytes32 => bytes32) public productsManufactured; // Maps product SN to manufacturer ID
    mapping(bytes32 => bytes32) public productsForSale; // Maps product SN to seller code
    mapping(bytes32 => bytes32) public productsSold; // Maps product SN to consumer code
    mapping(bytes32 => bytes32[]) public productsWithSeller; // Stores products associated with a seller
    mapping(bytes32 => bytes32[]) public productsWithConsumer; // Stores products associated with a consumer
    mapping(bytes32 => bytes32[]) public sellersWithManufacturer; // Stores sellers associated with a manufacturer

    // SELLER FUNCTIONS

    // Function to add a new seller
    function addSeller(
        bytes32 _manufacturerId,
        bytes32 _sellerName,
        bytes32 _sellerBrand,
        bytes32 _sellerCode,
        uint256 _sellerNum,
        bytes32 _sellerManager,
        bytes32 _sellerAddress
    ) public {
        sellers[sellerCount] = Seller({
            sellerId: sellerCount,
            sellerName: _sellerName,
            sellerBrand: _sellerBrand,
            sellerCode: _sellerCode,
            sellerNum: _sellerNum,
            sellerManager: _sellerManager,
            sellerAddress: _sellerAddress
        });
        sellerCount++;
        sellersWithManufacturer[_manufacturerId].push(_sellerCode); // Associate seller with manufacturer
    }

    // Function to update an existing seller
    function updateSeller(
        bytes32 _sellerCode,
        bytes32 _sellerName,
        bytes32 _sellerBrand,
        uint256 _sellerNum,
        bytes32 _sellerManager,
        bytes32 _sellerAddress
    ) public {
        uint256 sellerId = findSellerIdByCode(_sellerCode);
        sellers[sellerId].sellerName = _sellerName;
        sellers[sellerId].sellerBrand = _sellerBrand;
        sellers[sellerId].sellerNum = _sellerNum;
        sellers[sellerId].sellerManager = _sellerManager;
        sellers[sellerId].sellerAddress = _sellerAddress;
    }

    // Function to view all sellers
    function viewSellers() public view returns (
        uint256[] memory ids,
        bytes32[] memory snames,
        bytes32[] memory sbrands,
        bytes32[] memory scodes,
        uint256[] memory snums,
        bytes32[] memory smanagers,
        bytes32[] memory saddresses
    ) {
        uint256 length = sellerCount;
        ids = new uint256[](length);
        snames = new bytes32[](length);
        sbrands = new bytes32[](length);
        scodes = new bytes32[](length);
        snums = new uint256[](length);
        smanagers = new bytes32[](length);
        saddresses = new bytes32[](length);

        for (uint256 i = 0; i < length; i++) {
            Seller storage s = sellers[i];
            ids[i] = s.sellerId;
            snames[i] = s.sellerName;
            sbrands[i] = s.sellerBrand;
            scodes[i] = s.sellerCode;
            snums[i] = s.sellerNum;
            smanagers[i] = s.sellerManager;
            saddresses[i] = s.sellerAddress;
        }
    }

    // PRODUCT FUNCTIONS

    // Function to add a new product
    function addProduct(
        bytes32 _manufacturerID,
        bytes32 _productName,
        bytes32 _productSN,
        bytes32 _productBrand,
        uint256 _productPrice
    ) public {
        productItems[productCount] = ProductItem({
            productId: productCount,
            productSN: _productSN,
            productName: _productName,
            productBrand: _productBrand,
            productPrice: _productPrice,
            productStatus: "Available"
        });
        productMap[_productSN] = productCount;
        productCount++;
        productsManufactured[_productSN] = _manufacturerID;
    }

    // Function to update an existing product
    function updateProduct(
        bytes32 _productSN,
        bytes32 _productName,
        bytes32 _productBrand,
        uint256 _productPrice
    ) public {
        uint256 productId = productMap[_productSN];
        ProductItem storage product = productItems[productId];
        product.productName = _productName;
        product.productBrand = _productBrand;
        product.productPrice = _productPrice;
    }

    // Function to view all products
    function viewProductItems() public view returns (
        uint256[] memory pids,
        bytes32[] memory pSNs,
        bytes32[] memory pnames,
        bytes32[] memory pbrands,
        uint256[] memory pprices,
        bytes32[] memory pstatus
    ) {
        uint256 length = productCount;
        pids = new uint256[](length);
        pSNs = new bytes32[](length);
        pnames = new bytes32[](length);
        pbrands = new bytes32[](length);
        pprices = new uint256[](length);
        pstatus = new bytes32[](length);

        for (uint256 i = 0; i < length; i++) {
            ProductItem storage p = productItems[i];
            pids[i] = p.productId;
            pSNs[i] = p.productSN;
            pnames[i] = p.productName;
            pbrands[i] = p.productBrand;
            pprices[i] = p.productPrice;
            pstatus[i] = p.productStatus;
        }
    }

    // Function for manufacturer to sell a product
    function manufacturerSellProduct(bytes32 _productSN, bytes32 _sellerCode) public {
        productsWithSeller[_sellerCode].push(_productSN);
        productsForSale[_productSN] = _sellerCode;
    }

    // Function for seller to sell a product to a consumer
    function sellerSellProduct(bytes32 _productSN, bytes32 _consumerCode) public {
        uint256 productId = productMap[_productSN];
        ProductItem storage product = productItems[productId];

        require(keccak256(abi.encodePacked(product.productStatus)) == keccak256("Available"), "Product is not available");

        product.productStatus = "Sold"; // Update product status to sold
        productsWithConsumer[_consumerCode].push(_productSN);
        productsSold[_productSN] = _consumerCode;
    }

    // Function to query products listed by a seller
    function queryProductsList(bytes32 _sellerCode) public view returns (
        uint256[] memory pids,
        bytes32[] memory pSNs,
        bytes32[] memory pnames,
        bytes32[] memory pbrands,
        uint256[] memory pprices,
        bytes32[] memory pstatus
    ) {
        bytes32[] memory productSNs = productsWithSeller[_sellerCode];
        uint256 length = productSNs.length;

        pids = new uint256[](length);
        pSNs = new bytes32[](length);
        pnames = new bytes32[](length);
        pbrands = new bytes32[](length);
        pprices = new uint256[](length);
        pstatus = new bytes32[](length);

        for (uint256 i = 0; i < length; i++) {
            bytes32 productSN = productSNs[i];
            uint256 productId = productMap[productSN];
            ProductItem storage product = productItems[productId];

            pids[i] = product.productId;
            pSNs[i] = product.productSN;
            pnames[i] = product.productName;
            pbrands[i] = product.productBrand;
            pprices[i] = product.productPrice;
            pstatus[i] = product.productStatus;
        }
    }

    // Function to query seller list for a specific manufacturer
    function querySellersList(bytes32 _manufacturerCode) public view returns (
        uint256[] memory ids,
        bytes32[] memory snames,
        bytes32[] memory sbrands,
        bytes32[] memory scodes,
        uint256[] memory snums,
        bytes32[] memory smanagers,
        bytes32[] memory saddresses
    ) {
        bytes32[] memory sellerCodes = sellersWithManufacturer[_manufacturerCode];
        uint256 length = sellerCodes.length;

        ids = new uint256[](length);
        snames = new bytes32[](length);
        sbrands = new bytes32[](length);
        scodes = new bytes32[](length);
        snums = new uint256[](length);
        smanagers = new bytes32[](length);
        saddresses = new bytes32[](length);

        for (uint256 i = 0; i < length; i++) {
            bytes32 sellerCode = sellerCodes[i];
            uint256 sellerId = findSellerIdByCode(sellerCode);
            Seller storage s = sellers[sellerId];

            ids[i] = s.sellerId;
            snames[i] = s.sellerName;
            sbrands[i] = s.sellerBrand;
            scodes[i] = s.sellerCode;
            snums[i] = s.sellerNum;
            smanagers[i] = s.sellerManager;
            saddresses[i] = s.sellerAddress;
        }
    }

    // Helper function to find seller ID by seller code
    function findSellerIdByCode(bytes32 _sellerCode) internal view returns (uint256) {
        for (uint256 i = 0; i < sellerCount; i++) {
            if (sellers[i].sellerCode == _sellerCode) {
                return i;
            }
        }
        revert("Seller not found");
    }

    // Function to get purchase history of a consumer
    function getPurchaseHistory(bytes32 _consumerCode) public view returns (bytes32[] memory productSNs, bytes32[] memory sellerCodes, bytes32[] memory manufacturerCodes) {
        productSNs = productsWithConsumer[_consumerCode];
        sellerCodes = new bytes32[](productSNs.length);
        manufacturerCodes = new bytes32[](productSNs.length);

        for (uint256 i = 0; i < productSNs.length; i++) {
            sellerCodes[i] = productsForSale[productSNs[i]];
            manufacturerCodes[i] = productsManufactured[productSNs[i]];
        }

        return (productSNs, sellerCodes, manufacturerCodes);
    }

    // Function to verify if a product was purchased by a consumer
    function verifyProduct(bytes32 _productSN, bytes32 _consumerCode) public view returns (bool) {
        return productsSold[_productSN] == _consumerCode;
    }
}
