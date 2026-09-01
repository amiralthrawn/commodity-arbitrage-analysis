DROP TABLE IF EXISTS market_prices;
DROP TABLE IF EXISTS commodities;

CREATE TABLE commodities (
    commodity_id SERIAL PRIMARY KEY,
    commodity_name VARCHAR(50) NOT NULL,
    unit VARCHAR(20) NOT NULL
);

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE supplier_quotes (
    quote_id SERIAL PRIMARY KEY,

    supplier_id INTEGER NOT NULL,
    commodity_id INTEGER NOT NULL,

    quote_date DATE NOT NULL,
    delivery_month DATE NOT NULL,

    grade VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,

    benchmark VARCHAR(100) NOT NULL,
    differential NUMERIC(10, 4) NOT NULL,

    currency VARCHAR(10) NOT NULL DEFAULT 'USD',
    unit VARCHAR(20) NOT NULL DEFAULT 'bbl',

    source VARCHAR(255),

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id),

    FOREIGN KEY (commodity_id)
        REFERENCES commodities(commodity_id)
);

CREATE TABLE market_prices (
    price_id SERIAL PRIMARY KEY,
    commodity_id INTEGER NOT NULL,
    observation_date DATE NOT NULL,
    price DECIMAL(10,4) NOT NULL,

    FOREIGN KEY (commodity_id)
        REFERENCES commodities(commodity_id)
);