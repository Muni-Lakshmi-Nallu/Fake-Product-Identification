App = {

    web3Provider: null,
    contracts: {},

    init: async function() {
        return await App.initWeb3();
    },

    initWeb3: function() {
        if(window.web3) {
            App.web3Provider=window.web3.currentProvider;
        } else {
            App.web3Provider=new Web3.providers.HttpProvider('http://localhost:7545');
        }

        web3 = new Web3(App.web3Provider);
        return App.initContract();
    },

    initContract: function() {
        $.getJSON('product.json',function(data){
            var productArtifact=data;
            App.contracts.product=TruffleContract(productArtifact);
            App.contracts.product.setProvider(App.web3Provider);
        });

        return App.bindEvents();
    },

    bindEvents: function() {
        $(document).on('click','.btn-register',App.registerProduct);
        $(document).on('click','.btn-update-seller',App.updateSeller);
        $(document).on('click','.btn-update-product',App.updateProduct);
    },

    registerProduct: function(event) {
        event.preventDefault();

        var productInstance;

        var manufacturerID = document.getElementById('manufacturerID').value;
        var productName = document.getElementById('productName').value;
        var productSN = document.getElementById('productSN').value;
        var productBrand = document.getElementById('productBrand').value;
        var productPrice = document.getElementById('productPrice').value;

        window.ethereum.enable();

        web3.eth.getAccounts(function(error,accounts){
            if(error) {
                console.log(error);
            }

            var account=accounts[0];

            App.contracts.product.deployed().then(function(instance){
                productInstance=instance;
                return productInstance.addProduct(web3.fromAscii(manufacturerID),web3.fromAscii(productName), web3.fromAscii(productSN), web3.fromAscii(productBrand), productPrice, {from:account});
            }).then(function(result){
                document.getElementById('manufacturerID').value='';
                document.getElementById('productName').value='';
                document.getElementById('productSN').value='';
                document.getElementById('productBrand').value='';
                document.getElementById('productPrice').value='';
            }).catch(function(err){
                console.error("Error adding product:", err.message);
            });
        });
    },

    updateSeller: function(event) {
        event.preventDefault();

        var sellerCode = document.getElementById('sellerCode').value;
        var sellerName = document.getElementById('sellerName').value;
        var sellerBrand = document.getElementById('sellerBrand').value;
        var sellerNum = document.getElementById('sellerNum').value;
        var sellerManager = document.getElementById('sellerManager').value;
        var sellerAddress = document.getElementById('sellerAddress').value;

        window.ethereum.enable();

        web3.eth.getAccounts(function(error,accounts){
            if(error) {
                console.log(error);
            }

            var account=accounts[0];

            App.contracts.product.deployed().then(function(instance){
                return instance.updateSeller(
                    web3.fromAscii(sellerCode),
                    web3.fromAscii(sellerName),
                    web3.fromAscii(sellerBrand),
                    sellerNum,
                    web3.fromAscii(sellerManager),
                    web3.fromAscii(sellerAddress),
                    {from: account}
                );
            }).then(function(result){
                console.log("Seller updated successfully:", result);
            }).catch(function(err){
                console.error("Error updating seller:", err.message);
            });
        });
    },

    updateProduct: function(event) {
        event.preventDefault();

        var productSN = document.getElementById('productSN').value;
        var productName = document.getElementById('productName').value;
        var productBrand = document.getElementById('productBrand').value;
        var productPrice = document.getElementById('productPrice').value;

        window.ethereum.enable();

        web3.eth.getAccounts(function(error,accounts){
            if(error) {
                console.log(error);
            }

            var account=accounts[0];

            App.contracts.product.deployed().then(function(instance){
                return instance.updateProduct(
                    web3.fromAscii(productSN),
                    web3.fromAscii(productName),
                    web3.fromAscii(productBrand),
                    productPrice,
                    {from: account}
                );
            }).then(function(result){
                console.log("Product updated successfully:", result);
            }).catch(function(err){
                console.error("Error updating product:", err.message);
            });
        });
    }
};

$(function() {
    $(window).load(function() {
        App.init();
    });
});
