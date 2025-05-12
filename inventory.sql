CREATE TABLE Product_Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    parent_category_id INT NULL,
    description TEXT,
    FOREIGN KEY (parent_category_id) REFERENCES Product_Categories(category_id)
);

CREATE TABLE Brands (
    brand_id INT AUTO_INCREMENT PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE Units (
    unit_id INT AUTO_INCREMENT PRIMARY KEY,
    unit_name VARCHAR(100) NOT NULL,
    unit_code VARCHAR(20) NOT NULL
);

CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    status ENUM('active','inactive') DEFAULT 'active'
);

CREATE TABLE Warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    contact_person VARCHAR(255),
    contact_number VARCHAR(50),
    status ENUM('active','inactive') DEFAULT 'active'
);

CREATE TABLE Product_Attributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL,
    attribute_type VARCHAR(100) NOT NULL
);

CREATE TABLE Product_Attribute_Values (
    value_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_id INT,
    value VARCHAR(255) NOT NULL,
    FOREIGN KEY (attribute_id) REFERENCES Product_Attributes(attribute_id)
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(100) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT,
    brand_id INT,
    unit_id INT,
    purchase_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    min_stock_level INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('active','inactive') DEFAULT 'active',
    FOREIGN KEY (category_id) REFERENCES Product_Categories(category_id),
    FOREIGN KEY (brand_id) REFERENCES Brands(brand_id),
    FOREIGN KEY (unit_id) REFERENCES Units(unit_id)
);

CREATE TABLE Product_Variants (
    variant_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    sku VARCHAR(100) NOT NULL,
    variant_name VARCHAR(255),
    additional_price DECIMAL(10,2) DEFAULT 0,
    status ENUM('active','inactive') DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Product_Variant_Attributes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    variant_id INT,
    attribute_id INT,
    value_id INT,
    FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id),
    FOREIGN KEY (attribute_id) REFERENCES Product_Attributes(attribute_id),
    FOREIGN KEY (value_id) REFERENCES Product_Attribute_Values(value_id)
);

CREATE TABLE Product_Images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    variant_id INT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id)
);

CREATE TABLE Product_Barcodes (
    barcode_id INT AUTO_INCREMENT PRIMARY KEY,
    barcode_value VARCHAR(255) UNIQUE NOT NULL,
    product_id INT NULL,
    variant_id INT NULL,
    barcode_type VARCHAR(50),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id)
);

CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    variant_id INT NULL,
    warehouse_id INT,
    quantity_in_stock INT DEFAULT 0,
    available_quantity INT DEFAULT 0,
    reserved_quantity INT DEFAULT 0,
    last_checked_date DATETIME,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id)
);


CREATE TABLE Purchase_Orders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    order_date DATE,
    expected_delivery_date DATE,
    status ENUM('draft','confirmed','received','cancelled') DEFAULT 'draft',
    total_amount DECIMAL(15,2) DEFAULT 0,
    payment_terms VARCHAR(255),
    notes TEXT,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);


CREATE TABLE PO_Items (
    po_item_id INT AUTO_INCREMENT PRIMARY KEY,
    po_id INT,
    product_id INT,
    variant_id INT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    received_quantity INT DEFAULT 0,
    warehouse_id INT,
    FOREIGN KEY (po_id) REFERENCES Purchase_Orders(po_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id)
);


CREATE TABLE Inventory_Lots (
    lot_id INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT,
    lot_number VARCHAR(100),
    quantity INT DEFAULT 0,
    manufacture_date DATE,
    expiry_date DATE,
    supplier_id INT,
    po_item_id INT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    FOREIGN KEY (po_item_id) REFERENCES PO_Items(po_item_id)
);

CREATE TABLE Warehouse_Locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT,
    location_code VARCHAR(100) NOT NULL,
    location_type VARCHAR(50),
    parent_location_id INT NULL,
    status ENUM('active','inactive') DEFAULT 'active',
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id),
    FOREIGN KEY (parent_location_id) REFERENCES Warehouse_Locations(location_id)
);

CREATE TABLE Inventory_Locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT,
    lot_id INT NULL,
    location_id INT,
    quantity INT DEFAULT 0,
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id),
    FOREIGN KEY (lot_id) REFERENCES Inventory_Lots(lot_id),
    FOREIGN KEY (location_id) REFERENCES Warehouse_Locations(location_id)
);

CREATE TABLE Stock_Movements (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    variant_id INT NULL,
    warehouse_id INT,
    movement_type ENUM('purchase_receive', 'sale_out', 'transfer_in', 'transfer_out', 'return_from_customer', 'return_to_supplier', 'inventory_adjustment_add', 'inventory_adjustment_subtract', 'inventory_count_adjustment', 'damaged', 'expired', 'production_in', 'production_out') NOT NULL,
    quantity INT NOT NULL,
    reference_document VARCHAR(255),
    reference_id INT,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    notes TEXT,
    previous_quantity INT,
    new_quantity INT,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id)
);

CREATE TABLE Stock_Movements_Detail (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    movement_id INT,
    lot_id INT NULL,
    quantity INT DEFAULT 0,
    expiry_date DATE NULL,
    FOREIGN KEY (movement_id) REFERENCES Stock_Movements(movement_id),
    FOREIGN KEY (lot_id) REFERENCES Inventory_Lots(lot_id)
);

CREATE TABLE Stocktaking (
    stocktake_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT,
    start_date DATE,
    end_date DATE,
    status ENUM('in-progress','completed') DEFAULT 'in-progress',
    notes TEXT,
    created_by INT,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id)
);

CREATE TABLE Stocktake_Items (
    stocktake_item_id INT AUTO_INCREMENT PRIMARY KEY,
    stocktake_id INT,
    product_id INT,
    variant_id INT NULL,
    expected_quantity INT DEFAULT 0,
    actual_quantity INT DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (stocktake_id) REFERENCES Stocktaking(stocktake_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id)
);

CREATE TABLE Inventory_Audit_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT,
    movement_id INT NULL,
    previous_value JSON,
    new_value JSON,
    change_type VARCHAR(100),
    user_id INT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(100),
    note TEXT,
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id)
);
