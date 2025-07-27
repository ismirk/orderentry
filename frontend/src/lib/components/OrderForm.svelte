<script lang="ts">
    import { format } from 'date-fns';
    import type { Order, OrderDetails, Customer, Product } from '../types';
    import CustomerLookupModal from './CustomerLookupModal.svelte';
    import ProductLookupModal from './ProductLookupModal.svelte';
    import { apiCall } from '../../config';

    let order: Order = {
        order_date: format(new Date(), 'yyyy-MM-dd'),
        description: '',
        customer_code: '',
        customer_name: '',
        details: []
    };

    let showDetailsForm = false;
    let currentDetail: OrderDetails = {
        order_no: 1,
        product_code: '',
        product_name: '',
        unit_price: 0,
        qty: 1
    };

    // Customer lookup state
    let customerLookupModal: CustomerLookupModal;
    // Product lookup state
    let productLookupModal: ProductLookupModal;

    async function openCustomerLookup() {
        const customer = await customerLookupModal.openModal();
        if (customer) {
            order.customer_code = customer.customer_code;
            order.customer_name = customer.customer_name;
        }
    }

    async function openProductLookup() {
        const product = await productLookupModal.openModal();
        if (product) {
            currentDetail.product_code = product.product_code;
            currentDetail.product_name = product.product_name;
            currentDetail.unit_price = product.product_price;
        }
    }

    function addDetail() {
        order.details = [...order.details, { ...currentDetail }];
        currentDetail = {
            order_no: order.details.length + 1,
            product_code: '',
            product_name: '',
            unit_price: 0,
            qty: 1
        };
        showDetailsForm = false;
    }

    function removeDetail(index: number) {
        order.details = order.details.filter((_, i) => i !== index);
        // Update order numbers
        order.details = order.details.map((detail, i) => ({
            ...detail,
            order_no: i + 1
        }));
    }

    async function submitOrder() {
        try {
            console.log('Starting order submission...');
            console.log('Order data:', JSON.stringify(order, null, 2));
            
            const response = await apiCall('/api/orders/create/save', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(order)
            });

            console.log('Response status:', response.status);
            console.log('Response headers:', Object.fromEntries(response.headers.entries()));

            if (response.ok) {
                const data = await response.json();
                console.log('Success response:', data);
                alert('Order created successfully!');
                // Reset form
                order = {
                    order_date: format(new Date(), 'yyyy-MM-dd'),
                    description: '',
                    customer_code: '',
                    customer_name: '',
                    details: []
                };
            } else {
                const errorText = await response.text();
                console.error('Server error response:', errorText);
                alert(`Error creating order: ${errorText}`);
            }
        } catch (error) {
            console.error('Network or other error:', error);
            alert(`Error creating order: ${error.message}`);
        }
    }
</script>

<div class="container">
    <h1>Create New Order</h1>
    
    <form on:submit|preventDefault={submitOrder}>
        <div class="form-group">
            <label for="order_date">Order Date:</label>
            <input
                type="date"
                id="order_date"
                bind:value={order.order_date}
                required
            />
        </div>

        <div class="form-group">
            <label for="description">Description:</label>
            <input
                type="text"
                id="description"
                bind:value={order.description}
                required
            />
        </div>

        <div class="form-group">
            <label for="customer_code">Customer Code:</label>
            <div class="customer-input-group">
                <input
                    type="text"
                    id="customer_code"
                    bind:value={order.customer_code}
                    readonly
                    required
                    placeholder="Click 'Lookup Customer' to select"
                />
                <button type="button" on:click={openCustomerLookup} class="lookup-btn">
                    Lookup Customer
                </button>
            </div>
        </div>

        <div class="form-group">
            <label for="customer_name">Customer Name:</label>
            <input
                type="text"
                id="customer_name"
                bind:value={order.customer_name}
                readonly
                required
                placeholder="Will be filled automatically"
            />
        </div>

        <div class="order-details">
            <h2>Order Details</h2>
            
            {#if order.details.length > 0}
                <div class="details-list">
                    <table>
                        <thead>
                            <tr>
                                <th>No</th>
                                <th>Product Code</th>
                                <th>Product Name</th>
                                <th>Unit Price</th>
                                <th>Quantity</th>
                                <th>Subtotal</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            {#each order.details as detail, index}
                                <tr>
                                    <td>{detail.order_no}</td>
                                    <td>{detail.product_code}</td>
                                    <td>{detail.product_name}</td>
                                    <td>${detail.unit_price.toFixed(2)}</td>
                                    <td>{detail.qty}</td>
                                    <td>${(detail.unit_price * detail.qty).toFixed(2)}</td>
                                    <td>
                                        <button type="button" on:click={() => removeDetail(index)}>
                                            Remove
                                        </button>
                                    </td>
                                </tr>
                            {/each}
                        </tbody>
                    </table>
                </div>
            {/if}

            {#if showDetailsForm}
                <div class="detail-form">
                    <h3>Add New Item</h3>
                    <div class="form-group">
                        <label for="product_code">Product:</label>
                        <div class="product-input-group">
                            <input
                                type="text"
                                id="product_code"
                                bind:value={currentDetail.product_code}
                                readonly
                                required
                                placeholder="Click 'Lookup Product' to select"
                            />
                            <button type="button" on:click={openProductLookup} class="lookup-btn">
                                Lookup Product
                            </button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="product_name">Product Name:</label>
                        <input
                            type="text"
                            id="product_name"
                            bind:value={currentDetail.product_name}
                            readonly
                            required
                            placeholder="Will be filled automatically"
                        />
                    </div>

                    <div class="form-group">
                        <label for="unit_price">Unit Price:</label>
                        <input
                            type="number"
                            id="unit_price"
                            bind:value={currentDetail.unit_price}
                            min="0"
                            step="0.01"
                            required
                            readonly
                            placeholder="Will be filled automatically"
                        />
                    </div>

                    <div class="form-group">
                        <label for="qty">Quantity:</label>
                        <input
                            type="number"
                            id="qty"
                            bind:value={currentDetail.qty}
                            min="1"
                            required
                        />
                    </div>

                    <div class="button-group">
                        <button type="button" on:click={addDetail}>Add Item</button>
                        <button type="button" on:click={() => showDetailsForm = false}>Cancel</button>
                    </div>
                </div>
            {:else}
                <button type="button" on:click={() => showDetailsForm = true}>
                    Add New Item
                </button>
            {/if}
        </div>

        <div class="submit-section">
            <button type="submit" disabled={order.details.length === 0}>
                Create Order
            </button>
        </div>
    </form>
</div>

<!-- Customer Lookup Modal -->
<CustomerLookupModal bind:this={customerLookupModal} />

<!-- Product Lookup Modal -->
<ProductLookupModal bind:this={productLookupModal} />

<style>
    /* Override global centering styles */
    :global(body) {
        display: block !important;
        place-items: initial !important;
    }

    :global(#app) {
        margin: 0 !important;
        text-align: left !important;
        max-width: none !important;
        padding: 0 !important;
    }

    .container {
        max-width: 80%;
        width: 80%;
        margin: 0;
        padding: 20px;
        text-align: left;
        position: relative;
        left: 0;
    }

    h1 {
        text-align: left;
        margin-left: 0;
    }

    .form-group {
        margin-bottom: 15px;
        text-align: left;
    }

    label {
        display: block;
        margin-bottom: 5px;
        text-align: left;
    }

    input {
        width: 100%;
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
        text-align: left;
    }

    .customer-input-group, .product-input-group {
        display: flex;
        gap: 10px;
        align-items: flex-end;
    }

    .customer-input-group input, .product-input-group input {
        flex: 1;
    }

    .lookup-btn {
        white-space: nowrap;
        padding: 8px 16px;
        background-color: #007bff;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }

    .lookup-btn:hover {
        background-color: #0056b3;
    }

    .order-details {
        margin-top: 20px;
        text-align: left;
    }

    .details-list {
        margin-bottom: 20px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
        text-align: left;
    }

    th, td {
        padding: 8px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }

    th {
        background-color: #f5f5f5;
    }

    .detail-form {
        background-color: #f9f9f9;
        padding: 15px;
        border-radius: 4px;
        margin-bottom: 20px;
        text-align: left;
    }

    .button-group {
        display: flex;
        gap: 10px;
        margin-top: 15px;
        justify-content: flex-start;
    }

    button {
        padding: 8px 16px;
        background-color: #4CAF50;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }

    button:hover {
        background-color: #45a049;
    }

    button[type="button"] {
        background-color: #666;
    }

    button[type="button"]:hover {
        background-color: #555;
    }

    button:disabled {
        background-color: #cccccc;
        cursor: not-allowed;
    }

    .submit-section {
        margin-top: 20px;
        text-align: left;
    }
</style> 