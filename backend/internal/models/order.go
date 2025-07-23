package models

type Order struct {
	OrderID      int            `json:"order_id,omitempty"`
	OrderDate    SimpleDate     `json:"order_date"`
	Description  string         `json:"description"`
	CustomerCode string         `json:"customer_code"`
	Total        float64        `json:"total,omitempty"`
	Details      []OrderDetails `json:"details"`
}

type OrderDetails struct {
	OrderID     int     `json:"order_id,omitempty"`
	OrderNo     int     `json:"order_no"`
	ProductCode string  `json:"product_code"`
	ProductName string  `json:"product_name"`
	UnitPrice   float64 `json:"unit_price"`
	Qty         float64 `json:"qty"`
	Subtotal    float64 `json:"subtotal,omitempty"`
}

type Customer struct {
	CustomerCode string `json:"customer_code"`
	CustomerName string `json:"customer_name"`
}

type Product struct {
	ProductCode  string  `json:"product_code"`
	ProductName  string  `json:"product_name"`
	ProductPrice float64 `json:"product_price"`
}

// CalculateSubtotal calculates the subtotal for an order detail
func (d *OrderDetails) CalculateSubtotal() {
	d.Subtotal = d.UnitPrice * d.Qty
}

// CalculateTotal calculates the total for an order
func (o *Order) CalculateTotal() {
	o.Total = 0
	for i := range o.Details {
		o.Details[i].CalculateSubtotal()
		o.Total += o.Details[i].Subtotal
	}
}
