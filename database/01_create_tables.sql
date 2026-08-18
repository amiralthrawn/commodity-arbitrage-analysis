DROP TABLE IF EXISTS market_prices;
DROP TABLE IF EXISTS commodities;

CREATE TABLE commodities (
    commodity_id SERIAL PRIMARY KEY,
    commodity_name VARCHAR(50) NOT NULL,
    unit VARCHAR(20) NOT NULL
);

CREATE TABLE market_prices (
    price_id SERIAL PRIMARY KEY,
    commodity_id INTEGER NOT NULL,
    observation_date DATE NOT NULL,
    price DECIMAL(10,4) NOT NULL,

    FOREIGN KEY (commodity_id)
        REFERENCES commodities(commodity_id)
);