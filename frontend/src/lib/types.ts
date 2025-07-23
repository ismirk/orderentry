export interface OrderDetails {
    order_no: number;
    product_code: string;
    product_name: string;
    unit_price: number;
    qty: number;
}

export interface Order {
    order_date: string;
    description: string;
    customer_code: string;
    customer_name: string;
    details: OrderDetails[];
}

export interface Customer {
    customer_code: string;
    customer_name: string;
}

export interface CustomerLookupResponse {
    num_rows: number;
    data: Customer[];
    total_pages: number;
    is_empty: boolean;
}

export interface Product {
    product_code: string;
    product_name: string;
    product_price: number;
}

export interface ProductLookupResponse {
    num_rows: number;
    data: Product[];
    total_pages: number;
    is_empty: boolean;
} 