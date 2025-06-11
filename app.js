import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import ProductContract from './Product.json'; // ABI file

const App = () => {
    const [account, setAccount] = useState('');
    const [contract, setContract] = useState(null);
    const [sellerData, setSellerData] = useState({});
    const [productData, setProductData] = useState({});
    const [sellers, setSellers] = useState([]);
    const [products, setProducts] = useState([]);

    const web3 = new Web3(window.ethereum);
    const contractAddress = 'YOUR_CONTRACT_ADDRESS'; // Replace with your contract address

    useEffect(() => {
        const init = async () => {
            const accounts = await web3.eth.requestAccounts();
            setAccount(accounts[0]);
            const instance = new web3.eth.Contract(ProductContract.abi, contractAddress);
            setContract(instance);
            loadSellers(instance);
            loadProducts(instance);
        };
        init();
    }, []);

    const loadSellers = async (instance) => {
        const sellerCount = await instance.methods.sellerCount().call();
        const sellersList = [];
        for (let i = 0; i < sellerCount; i++) {
            const seller = await instance.methods.sellers(i).call();
            sellersList.push(seller);
        }
        setSellers(sellersList);
    };

    const loadProducts = async (instance) => {
        const productCount = await instance.methods.productCount().call();
        const productsList = [];
        for (let i = 0; i < productCount; i++) {
            const product = await instance.methods.productItems(i).call();
            productsList.push(product);
        }
        setProducts(productsList);
    };

    const addSeller = async () => {
        await contract.methods.addSeller(
            web3.utils.asciiToHex('MANUFACTURER_ID'), // Replace with actual manufacturer ID
            web3.utils.asciiToHex(sellerData.name),
            web3.utils.asciiToHex(sellerData.brand),
            web3.utils.asciiToHex(sellerData.code),
            sellerData.num,
            web3.utils.asciiToHex(sellerData.manager),
            web3.utils.asciiToHex(sellerData.address)
        ).send({ from: account });
        loadSellers(contract);
    };

    const addProduct = async () => {
        await contract.methods.addProduct(
            web3.utils.asciiToHex('MANUFACTURER_ID'), // Replace with actual manufacturer ID
            web3.utils.asciiToHex(productData.name),
            web3.utils.asciiToHex(productData.serialNumber),
            web3.utils.asciiToHex(productData.brand),
            productData.price
        ).send({ from: account });
        loadProducts(contract);
    };

    return (
        <div>
            <h1>Product and Seller Management</h1>
            <h2>Add Seller</h2>
            <input type="text" placeholder="Name" onChange={(e) => setSellerData({ ...sellerData, name: e.target.value })} />
            <input type="text" placeholder="Brand" onChange={(e) => setSellerData({ ...sellerData, brand: e.target.value })} />
            <input type="text" placeholder="Code" onChange={(e) => setSellerData({ ...sellerData, code: e.target.value })} />
            <input type="number" placeholder="Number" onChange={(e) => setSellerData({ ...sellerData, num: e.target.value })} />
            <input type="text" placeholder="Manager" onChange={(e) => setSellerData({ ...sellerData, manager: e.target.value })} />
            <input type="text" placeholder="Address" onChange={(e) => setSellerData({ ...sellerData, address: e.target.value })} />
            <button onClick={addSeller}>Add Seller</button>

            <h2>Add Product</h2>
            <input type="text" placeholder="Product Name" onChange={(e) => setProductData({ ...productData, name: e.target.value })} />
            <input type="text" placeholder="Product Serial Number" onChange={(e) => setProductData({ ...productData, serialNumber: e.target.value })} />
            <input type="text" placeholder="Product Brand" onChange={(e) => setProductData({ ...productData, brand: e.target.value })} />
            <input type="number" placeholder="Product Price" onChange={(e) => setProductData({ ...productData, price: e.target.value })} />
            <button onClick={addProduct}>Add Product</button>

            <h2>Sellers</h2>
            <ul>
                {sellers.map((seller, index) => (
                    <li key={index}>
                        {web3.utils.hexToAscii(seller.sellerName)} - {web3.utils.hexToAscii(seller.sellerBrand)}
                    </li>
                ))}
            </ul>

            <h2>Products</h2>
            <ul>
                {products.map((product, index) => (
                    <li key={index}>
                        {web3.utils.hexToAscii(product.productName)} - {web3.utils.hexToAscii(product.productBrand)}
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default App;