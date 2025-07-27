<script lang="ts">
    import type { Customer, CustomerLookupResponse } from '../types';
    import { createEventDispatcher } from 'svelte';
    import { apiCall } from '../../config';

    const dispatch = createEventDispatcher();

    export let isOpen: boolean = false;

    let customers: Customer[] = [];
    let currentPage = 1;
    let totalPages = 1;
    let customerNameFilter = '';
    let isLoadingCustomers = false;
    let resolvePromise: ((customer: Customer | null) => void) | null = null;

    async function loadCustomers(page: number = 1, nameFilter: string = '') {
        isLoadingCustomers = true;
        try {
            const params = new URLSearchParams({
                page: page.toString()
            });
            
            if (nameFilter.trim()) {
                params.append('customer_name', nameFilter.trim());
            }
            const response = await apiCall(`/api/orders/create/lookup_customer?${params}`);
            
            if (response.ok) {
                const data: CustomerLookupResponse = await response.json();
                customers = data.data;
                totalPages = data.total_pages;
                currentPage = page;
            } else {
                console.error('Failed to load customers');
                throw new Error('Failed to load customers');
            }
        } catch (error) {
            console.error('Error loading customers:', error);
            throw error;
        } finally {
            isLoadingCustomers = false;
        }
    }

    function handleSelectCustomer(customer: Customer) {
        if (resolvePromise) {
            resolvePromise(customer);
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
        customers = [];
        currentPage = 1;
        customerNameFilter = '';
        resolvePromise = null;
        dispatch('close');
    }

    function nextPage() {
        if (currentPage < totalPages) {
            loadCustomers(currentPage + 1, customerNameFilter);
        }
    }

    function prevPage() {
        if (currentPage > 1) {
            loadCustomers(currentPage - 1, customerNameFilter);
        }
    }

    function searchCustomers() {
        loadCustomers(1, customerNameFilter);
    }

    // Watch for modal opening to load customers
    $: if (isOpen && customers.length === 0) {
        currentPage = 1;
        customerNameFilter = '';
        loadCustomers(1).catch(error => {
            console.error('Failed to load customers:', error);
            if (resolvePromise) {
                resolvePromise(null);
            }
        });
    }

    // Export async function to open modal and wait for selection
    export async function openModal(): Promise<Customer | null> {
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
                <h2>Select Customer</h2>
                <button type="button" class="close-btn" on:click={handleClose}>&times;</button>
            </div>
            
            <div class="modal-body">
                <div class="search-section">
                    <input
                        type="text"
                        placeholder="Search by customer name..."
                        bind:value={customerNameFilter}
                        on:keydown={(e) => e.key === 'Enter' && searchCustomers()}
                    />
                    <button type="button" on:click={searchCustomers} disabled={isLoadingCustomers}>
                        Search
                    </button>
                </div>

                {#if isLoadingCustomers}
                    <div class="loading">Loading customers...</div>
                {:else if customers.length === 0}
                    <div class="no-results">No customers found</div>
                {:else}
                    <div class="customers-list">
                        <table>
                            <thead>
                                <tr>
                                    <th>Customer Code</th>
                                    <th>Customer Name</th>
                                </tr>
                            </thead>
                            <tbody>
                                {#each customers as customer}
                                    <tr 
                                        on:click={() => handleSelectCustomer(customer)} 
                                        on:keydown={(e) => e.key === 'Enter' && handleSelectCustomer(customer)}
                                        tabindex="0"
                                        class="customer-row"
                                        role="button"
                                        aria-label="Select customer {customer.customer_name}"
                                    >
                                        <td>{customer.customer_code}</td>
                                        <td>{customer.customer_name}</td>
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

    .customers-list {
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

    .customer-row {
        cursor: pointer;
    }

    .customer-row:hover {
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