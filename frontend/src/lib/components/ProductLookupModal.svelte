<script lang="ts">
    import type { Product, ProductLookupResponse } from '../types';
    import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    export let isOpen: boolean = false;

    let products: Product[] = [];
    let currentPage = 1;
    let totalPages = 1;
    let productNameFilter = '';
    let isLoadingProducts = false;
    let resolvePromise: ((product: Product | null) => void) | null = null;

    async function loadProducts(page: number = 1, nameFilter: string = '') {
        isLoadingProducts = true;
        try {
            const params = new URLSearchParams({
                page: page.toString()
            });
            
            if (nameFilter.trim()) {
                params.append('product_name', nameFilter.trim());
            }

            const response = await fetch(`/api/orders/create/lookup_product?${params}`);
            
            if (response.ok) {
                const data: ProductLookupResponse = await response.json();
                products = data.data;
                totalPages = data.total_pages;
                currentPage = page;
            } else {
                console.error('Failed to load products');
                throw new Error('Failed to load products');
            }
        } catch (error) {
            console.error('Error loading products:', error);
            throw error;
        } finally {
            isLoadingProducts = false;
        }
    }

    function handleSelectProduct(product: Product) {
        if (resolvePromise) {
            resolvePromise(product);
            closeModal();
        }
    }

    function handleClose() {
        if (resolvePromise) {
            resolvePromise(null);
        }
        closeModal();
    }

    function closeModal() {
        isOpen = false;
        products = [];
        currentPage = 1;
        productNameFilter = '';
        resolvePromise = null;
        dispatch('close');
    }

    function nextPage() {
        if (currentPage < totalPages) {
            loadProducts(currentPage + 1, productNameFilter);
        }
    }

    function prevPage() {
        if (currentPage > 1) {
            loadProducts(currentPage - 1, productNameFilter);
        }
    }

    function searchProducts() {
        loadProducts(1, productNameFilter);
    }

    // Watch for modal opening to load products
    $: if (isOpen && products.length === 0) {
        currentPage = 1;
        productNameFilter = '';
        loadProducts(1).catch(error => {
            console.error('Failed to load products:', error);
            if (resolvePromise) {
                resolvePromise(null);
            }
        });
    }

    // Export async function to open modal and wait for selection
    export async function openModal(): Promise<Product | null> {
        return new Promise((resolve) => {
            resolvePromise = resolve;
            isOpen = true;
        });
    }
</script>

{#if isOpen}
    <div class="modal-overlay" on:click={handleClose}>
        <div class="modal-content" on:click|stopPropagation>
            <div class="modal-header">
                <h2>Select Product</h2>
                <button type="button" class="close-btn" on:click={handleClose}>&times;</button>
            </div>
            
            <div class="modal-body">
                <div class="search-section">
                    <input
                        type="text"
                        placeholder="Search by product name..."
                        bind:value={productNameFilter}
                        on:keydown={(e) => e.key === 'Enter' && searchProducts()}
                    />
                    <button type="button" on:click={searchProducts} disabled={isLoadingProducts}>
                        Search
                    </button>
                </div>

                {#if isLoadingProducts}
                    <div class="loading">Loading products...</div>
                {:else if products.length === 0}
                    <div class="no-results">No products found</div>
                {:else}
                    <div class="products-list">
                        <table>
                            <thead>
                                <tr>
                                    <th>Product Code</th>
                                    <th>Product Name</th>
                                    <th>Price</th>
                                </tr>
                            </thead>
                            <tbody>
                                {#each products as product}
                                    <tr 
                                        on:click={() => handleSelectProduct(product)} 
                                        on:keydown={(e) => e.key === 'Enter' && handleSelectProduct(product)}
                                        tabindex="0"
                                        class="product-row"
                                        role="button"
                                        aria-label="Select product {product.product_name}"
                                    >
                                        <td>{product.product_code}</td>
                                        <td>{product.product_name}</td>
                                        <td>${product.product_price.toFixed(2)}</td>
                                    </tr>
                                {/each}
                            </tbody>
                        </table>
                    </div>

                    <div class="pagination">
                        <button type="button" on:click={prevPage} disabled={currentPage <= 1}>
                            Previous
                        </button>
                        <span class="page-info">Page {currentPage} of {totalPages}</span>
                        <button type="button" on:click={nextPage} disabled={currentPage >= totalPages}>
                            Next
                        </button>
                    </div>
                {/if}
            </div>
        </div>
    </div>
{/if}

<style>
    /* Modal Styles */
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 1000;
    }

    .modal-content {
        background-color: white;
        border-radius: 8px;
        width: 90%;
        max-width: 600px;
        max-height: 80vh;
        overflow: hidden;
        display: flex;
        flex-direction: column;
    }

    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px;
        border-bottom: 1px solid #ddd;
    }

    .modal-header h2 {
        margin: 0;
    }

    .close-btn {
        background: none;
        border: none;
        font-size: 24px;
        cursor: pointer;
        color: #666;
    }

    .close-btn:hover {
        color: #000;
    }

    .modal-body {
        padding: 20px;
        overflow-y: auto;
    }

    .search-section {
        display: flex;
        gap: 10px;
        margin-bottom: 20px;
    }

    .search-section input {
        flex: 1;
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
    }

    .products-list {
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

    .product-row {
        cursor: pointer;
    }

    .product-row:hover {
        background-color: #f5f5f5;
    }

    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 15px;
        margin-top: 20px;
    }

    .page-info {
        font-weight: bold;
    }

    .loading, .no-results {
        text-align: center;
        padding: 20px;
        color: #666;
    }

    button {
        padding: 8px 16px;
        background-color: #007bff;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }

    button:hover {
        background-color: #0056b3;
    }

    button:disabled {
        background-color: #cccccc;
        cursor: not-allowed;
    }
</style> 